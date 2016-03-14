require "log4r"

module VagrantPlugins
  module XenServer
    module Action
      class SetVMParams
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::set_vm_params")
        end
        
        def call(env)
          myvm = env[:machine].id

          if env[:machine].provider_config.pv
            env[:xc].VM.set_HVM_boot_policy(myvm,"")
            env[:xc].VM.set_PV_bootloader(myvm,"pygrub")
          end

          mem = ((env[:machine].provider_config.memory) * (1024*1024)).to_s
          env[:xc].VM.set_memory_limits(myvm,mem,mem,mem,mem)

          @app.call env
        end
      end
    end
  end
end
