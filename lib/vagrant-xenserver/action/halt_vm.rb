require "log4r"
require "xmlrpc/client"

module VagrantPlugins
  module XenServer
    module Action
      class HaltVM
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::halt_vm")
        end
        
        def call(env)
          myvm = env[:machine].id
          
          shutdown_result = env[:xc].VM.clean_shutdown(myvm)

          @app.call env
        end
      end
    end
  end
end
