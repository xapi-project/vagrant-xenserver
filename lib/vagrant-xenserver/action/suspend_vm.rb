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
          
          suspend_task = env[:xc].call("Async.VM.suspend",env[:session],myvm)['Value']
          while env[:xc].call("task.get_status",env[:session],suspend_task)['Value'] == 'pending' do
              sleep 1
          end
          suspend_result = env[:xc].call("task.get_status",env[:session],suspend_task)['Value']
          if suspend_result != "success"
            raise Errors::APIError
          end
          
          @app.call env
        end
      end
    end
  end
end
