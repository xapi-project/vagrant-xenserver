require 'socket'
require 'rbconfig'

require "vagrant-xenserver/util/xe"

def os
    @os ||= (
      host_os = RbConfig::CONFIG['host_os']
      case host_os
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        :windows
      when /darwin|mac os/
        :macosx
      when /linux/
        :linux
      when /solaris|bsd/
        :unix
      else
        raise Vagrant::Errors::UnknownOS # "unknown os: #{host_os.inspect}"
      end
    )
  end


module VagrantPlugins
  module XenServer
    module Action
      class PrepareNFSSettings
        include Vagrant::Action::Builtin::MixinSyncedFolders

        def initialize(app,env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::action::vm::nfs")
        end

        def call(env)
          @machine = env[:machine]
          @app.call(env)

          if using_nfs?
            @logger.info("Using NFS, preparing NFS settings by reading host IP and machine IP")

            env[:nfs_host_ip]    = read_host_ip(env[:machine],env)

            has_public_network = false
            bridge = nil
            # First, check if there is public_network defined in Vagrantfile
            # since we don't know which interface is ablt to connect to
            # NFS Server, assume the last one
            env[:machine].config.vm.networks.each do |type, options|
              next if type == :forwarded_port

              if type == :public_network then
                has_public_network = true
                bridge = options[:bridge]
              end
            end

            if has_public_network then
              # I don't know the xmlrpc call to get IP address on a VIF, assume
              # XenTools is installed, we can get IP from `xe vm-list` command

              # Get VM UUID
              vm_result = env[:xc].call("VM.get_record",env[:session],env[:machine].id)['Value']
              # Get all Networks
              networks = env[:xc].call("network.get_all_records",env[:session])['Value']

              # Find which network has the bridge name match in Vagrantfile
              xenbr_net = networks.find { |ref,net| net['bridge'] == bridge }
              (ref, xenbr_rec) = xenbr_net

              # Find the VIF's "device" number, device 2 is eth2 in centos guest
              xenbr_vif = xenbr_rec['VIFs'].find { |vif| vm_result['VIFs'].include? vif }
              vif = env[:xc].call("VIF.get_record",env[:session], xenbr_vif)['Value']

              vm_uuid = vm_result['uuid']
              @logger.info("VM UUID: #{vm_uuid}, #{bridge} network name-label \"#{xenbr_rec['name_label']}\"")

              # Get VM IP
              # FIXME: stupidly append env to the end, don't know the proper way
              #         so that xe.rb can read Vagrantfile config
              re = /#{vif['device']}\/ip:\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3});/
              cmd = ["vm-list uuid=#{vm_result['uuid']} params=networks --minimal", env]
              match = Xe::XEViaSSH.new(*cmd).execute.stdout.chomp.match re

              if not match.nil?
                vm_ip = match[1]
                @logger.info("VM nic on #{bridge} is eth#{vif['device']} with IPv4 address: #{vm_ip}")

                # Finally, we know what to put in /etc/exports
                env[:nfs_machine_ip] = vm_ip
                @logger.info("host IP: #{env[:nfs_host_ip]} machine IP: #{env[:nfs_machine_ip]}")

              else
                raise Vagrant::Errors::NFSNoGuestIP
              end
            else

              # Original code
              env[:nfs_machine_ip] = env[:xs_host_ip]
              @logger.info("host IP: #{env[:nfs_host_ip]} machine IP: #{env[:nfs_machine_ip]}")

              raise Vagrant::Errors::NFSNoHostonlyNetwork if !env[:nfs_machine_ip] || !env[:nfs_host_ip]
            end
          end
        end

        # We're using NFS if we have any synced folder with NFS configured. If
        # we are not using NFS we don't need to do the extra work to
        # populate these fields in the environment.
        def using_nfs?
          !!synced_folders(@machine)[:nfs]
        end

        # Returns the IP address of the interface that will route to the xs_host
        #
        # @param [Machine] machine
        # @return [String]
        def read_host_ip(machine,env)
          ip = Socket.getaddrinfo(env[:machine].provider_config.xs_host,nil)[0][2]
          env[:xs_host_ip] = ip
          def get_local_ip_linux(ip)
            re = /src ([0-9\.]+)/
            match = `ip route get to #{ip} | head -n 1`.match re
            match[1]
          end
          def get_local_ip_mac(ip)
            re = /interface: ([a-z0-9]+)/
            match = `route get #{ip} | grep interface | head -n 1`.match re
            interface = match[1]
            re = /inet ([0-9\.]+)/
            match = `ifconfig #{interface} inet | tail -1`.match re
            match[1]
          end
          def get_local_ip_win(ip)
            error = "For NFS in windows, you need to install vagrant-winnfsd plugin, and put the winnfsd executable on Vagrant's bin directory"
            raise error unless Vagrant.has_plugin? "vagrant-winnfsd"

            # Assume default gateway interface has IP address which reachable from Xenserver Host
            re = /^.*0\.0\.0\.0\s+\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).*$/
            match = `route -4 PRINT 0.0.0.0`.match re
            match[1]
          end
          if os == :linux then get_local_ip_linux(ip)
          elsif os == :macosx then get_local_ip_mac(ip)
          elsif os == :windows then get_local_ip_win(ip)
          else raise Vagrant::Errors::UnknownOS # "unknown os: #{host_os.inspect}"
          end
        end
      end
    end
  end
end
