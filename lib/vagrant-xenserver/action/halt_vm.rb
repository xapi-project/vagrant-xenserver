require "log4r"
require "xmlrpc/client"

module VagrantPlugins
  module XenServer
    module Action
      class HaltVM
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::start_vm")
        end
        
        def call(env)
          myvm = env[:machine].id
          
          shutdown_result = env[:xc].call("VM.clean_shutdown",env[:session],myvm)

          if shutdown_result["Status"] != "Success"
            raise Errors::APIError
          end
          
          @app.call env
        end
      end
    end
  end
end
