require 'nokogiri'
require 'socket'

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
          @logger.info("XXXXXX Here!")
          @app.call(env)          
          @logger.info("XXXXXX now Here!")

          if using_nfs?
            @logger.info("Using NFS, preparing NFS settings by reading host IP and machine IP")
            env[:nfs_host_ip]    = read_host_ip(env[:machine],env)
            env[:nfs_machine_ip] = env[:xs_host_ip]

            @logger.info("host IP: #{env[:nfs_host_ip]} machine IP: #{env[:nfs_machine_ip]}")

            raise Vagrant::Errors::NFSNoHostonlyNetwork if !env[:nfs_machine_ip] || !env[:nfs_host_ip]
          end
        end

        # We're using NFS if we have any synced folder with NFS configured. If
        # we are not using NFS we don't need to do the extra work to
        # populate these fields in the environment.
        def using_nfs?
          true
#          !!synced_folders(@machine)[:nfs]
        end

        # Returns the IP address of the first host only network adapter
        #
        # @param [Machine] machine
        # @return [String]
        def read_host_ip(machine,env)
          ip = Socket.getaddrinfo(env[:machine].provider_config.xs_host,nil)[0][2]
          env[:xs_host_ip] = ip
          re = /src ([0-9\.]+)/
          match = `ip route get to #{ip} | head -n 1`.match re
          match[1]
        end
      end
    end
  end
end
