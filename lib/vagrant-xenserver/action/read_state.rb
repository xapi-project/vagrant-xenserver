require "log4r"

module VagrantPlugins
  module XenServer
    module Action
      class ReadState
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant_xenserver::action::read_state")
        end

        def call(env)
          env[:machine_state_id] = read_state(env[:xc], env[:session], env[:machine])

          @app.call(env)
        end

        def read_state(xc, session, machine)
          return :not_created if machine.id.nil?

          result = xc.call("VM.get_record",session,machine.id)

          if result["Status"] != "Success"
            @logger.info("Machine not found. Assuming it has been destroyed.")
            machine.id = nil
            return :not_created
          end
          
          return result["Value"]['power_state']
        end
      end
    end
  end
end
