require "log4r"

module VagrantPlugins
  module XenServer
    module Action
      # This action reads the SSH info for the machine and puts it into the
      # `:machine_ssh_info` key in the environment.
      class ReadSSHInfo
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_xenserver::action::read_ssh_info")
        end

        def call(env)
          env[:machine_ssh_info] = read_ssh_info(env)

          @app.call(env)
        end

        def read_ssh_info(env)
          machine = env[:machine]
          return nil if machine.id.nil?

          # Find the machine
          networks = env[:xc].network.get_all_records

          begin
            vifs = env[:xc].VM.get_VIFs(machine.id)
          rescue
            @logger.info("Machine couldn't be found, assuming it got destroyed.")
            machine.id = nil
            return nil
          end
            
          himn = networks.find { |ref,net| net['other_config']['is_host_internal_management_network'] }
          (himn_ref,himn_rec) = himn
            
          assigned_ips = himn_rec['assigned_ips']
          (vif,ip) = assigned_ips.find { |vif,ip| vifs.include? vif }

          ssh_info = {
            :host          => ip,
            :port          => machine.config.ssh.guest_port,
            :username      => machine.config.ssh.username,
            :forward_agent => machine.config.ssh.forward_agent,
            :forward_x11   => machine.config.ssh.forward_x11,
          }
          
          ssh_info[:proxy_command] = "ssh '#{machine.provider_config.xs_host}' -l '#{machine.provider_config.xs_username}' nc %h %p"

          if not ssh_info[:username]
            ssh_info[:username] = machine.config.ssh.default.username
          end

          ssh_info
        end
      end
    end
  end
end
