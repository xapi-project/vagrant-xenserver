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
          
          resume_task = env[:xc].Async.VM.resume(myvm,false,false)
          while env[:xc].task.get_status(resume_task) == 'pending' do
              sleep 1
          end
          resume_result = env[:xc].task.get_status(resume_task)
          if resume_result != "success"
            raise Errors::APIError
          end
          
          @app.call env
        end
      end
    end
  end
end
