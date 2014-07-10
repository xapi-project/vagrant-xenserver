require "log4r"

module VagrantPlugins
  module XenServer
    module Action
      class ReadState
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::read_state")
        end

        def call(env)
          @logger.debug("XXXXX In ReadState")
          env[:machine_state_id] = read_state(env[:xc], env[:session], env[:machine])
          @logger.debug("state="+env[:machine_state_id].to_s)
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
