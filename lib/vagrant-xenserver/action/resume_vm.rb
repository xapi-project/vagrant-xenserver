require "log4r"
require "xmlrpc/client"

module VagrantPlugins
  module XenServer
    module Action
      class ResumeVM
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::resume_vm")
        end
        
        def call(env)
          myvm = env[:machine].id
          
          resume_task = env[:xc].call("Async.VM.resume",env[:session],myvm,false,false)['Value']
          while env[:xc].call("task.get_status",env[:session],resume_task)['Value'] == 'pending' do
              sleep 1
          end
          resume_result = env[:xc].call("task.get_status",env[:session],resume_task)['Value']
          if resume_result != "success"
            raise Errors::APIError
          end
          
          @app.call env
        end
      end
    end
  end
end
