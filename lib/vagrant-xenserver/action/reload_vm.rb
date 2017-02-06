require "log4r"
require "xmlrpc/client"

module VagrantPlugins
  module XenServer
    module Action
      class ReloadVM
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::reload_vm")
        end

        def call(env)
          myvm = env[:machine].id

          reboot_task = env[:xc].Async.VM.reboot(myvm,false,false)
          while env[:xc].task.get_status(reboot_task) == 'pending' do
              sleep 1
          end
          reboot_result = env[:xc].task.get_status(reboot_task)
          if reboot_result != "success"
            raise Errors::APIError
          end

          @app.call env
        end
      end
    end
  end
end
