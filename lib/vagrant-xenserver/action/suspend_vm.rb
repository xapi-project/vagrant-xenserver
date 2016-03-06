require "log4r"
require "xmlrpc/client"

module VagrantPlugins
  module XenServer
    module Action
      class SuspendVM
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::suspend_vm")
        end
        
        def call(env)
          myvm = env[:machine].id
          
          suspend_task = env[:xc].Async.VM.suspend(myvm)
          while env[:xc].task.get_status(suspend_task) == 'pending' do
              sleep 1
          end
          suspend_result = env[:xc].task.get_status(suspend_task)
          if suspend_result != "success"
            raise Errors::APIError
          end
          
          @app.call env
        end
      end
    end
  end
end
