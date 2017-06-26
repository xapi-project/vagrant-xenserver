require "log4r"
require "xmlrpc/client"

module VagrantPlugins
  module XenServer
    module Action
      class CloneVM
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::clone_vm")
        end

        def call(env)
          template_ref = env[:template]
          box_name = env[:machine].box.name.to_s
          box_version = env[:machine].box.version.to_s
          username = Etc.getlogin
          
          if env[:machine].provider_config.name.nil?
            vm_name = "#{username}/#{box_name}/#{box_version}"
          else
            vm_name = env[:machine].provider_config.name
          end

          vm = nil
          Action.getlock.synchronize do
            vm = env[:xc].VM.clone(template_ref, vm_name)
            env[:xc].VM.provision(vm)
          end

          env[:machine].id = vm

          @app.call env
        end
      end
    end
  end
end
