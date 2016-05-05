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

          # Find the vm guest metrics
          gm_ref = env[:xc].call("VM.get_guest_metrics",env[:session],machine.id)['Value']

          # Get the assigned networks
          networks = env[:xc].call("VM_guest_metrics.get_networks",env[:session],gm_ref)['Value']
          if networks && networks.values[0]
            ip = networks.values[0]

            ssh_info = {
              :host          => ip,
              :port          => machine.config.ssh.guest_port,
              :username      => machine.config.ssh.username,
              :forward_agent => machine.config.ssh.forward_agent,
              :forward_x11   => machine.config.ssh.forward_x11,
            }

            if not ssh_info[:username]
              ssh_info[:username] = machine.config.ssh.default.username
            end

            @logger.info("ssh host: " + ssh_info[:host])
            ssh_info
          else
            ssh_info = nil
            ssh_info
          end
        end
      end
    end
  end
end
