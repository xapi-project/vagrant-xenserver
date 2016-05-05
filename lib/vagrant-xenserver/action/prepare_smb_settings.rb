require 'nokogiri'
require 'socket'
require 'rbconfig'

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
      class PrepareSMBSettings
        include Vagrant::Action::Builtin::MixinSyncedFolders
        
        def initialize(app,env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::action::vm::smb")
        end

        def call(env)
          @machine = env[:machine]
          @app.call(env)          

          if using_smb?
            @logger.info("Using SMB, preparing SMB settings by reading host IP and machine IP")
            env[:smb_host_ip]    = read_host_ip(env[:machine],env)
            #env[:smb_machine_ip] = env[:xs_host_ip]
            env[:smb_machine_ip] = "*"

            @logger.info("host IP: #{env[:smb_host_ip]} machine IP: #{env[:smb_machine_ip]}")

            raise Vagrant::Errors::NFSNoHostonlyNetwork if !env[:smb_machine_ip] || !env[:smb_host_ip]
          end
        end

        # We're using SMB if we have any synced folder with SMB configured. If
        # we are not using SMB we don't need to do the extra work to
        # populate these fields in the environment.
        def using_smb?
          !!synced_folders(@machine)[:smb]
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
          if os == :linux then get_local_ip_linux(ip)
          elsif os == :macosx then get_local_ip_mac(ip)
          else raise Vagrant::Errors::UnknownOS # "unknown os: #{host_os.inspect}"
          end 
        end
      end
    end
  end
end
