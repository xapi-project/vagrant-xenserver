require "log4r"
require "xmlrpc/client"
require "vagrant-xenserver/util/uploader"
require "rexml/document"
require "json"
require "etc"

module VagrantPlugins
  module XenServer
    module Action
      class CreateVM
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::create_vm")
        end
        
        def call(env)
          username = Etc.getlogin
          data_dir = env[:machine].data_dir
          box_name = env[:machine].box.name.to_s
          box_version = env[:machine].box.version.to_s

          vm_name = "#{username}/#{data_dir}/#{box_name}/#{box_version}"

          box_type = env[:machine].provider_config.box_type
          vm_ref = case box_type
                   when "vhd"
                     CreateVMFromVHD(env, vm_name)
                   when "xva"
                     CreateVMFromTemplate(env, box_name, box_version, vm_name)
                   else
                     raise Vagrant::Errors::ConfigInvalid("box_type is invalid or not specified")
                   end

          if env[:machine].provider_config.pv
            env[:xc].call("VM.set_HVM_boot_policy",env[:session],vm_ref,"")
            env[:xc].call("VM.set_PV_bootloader",env[:session],vm_ref,"pygrub")
          end

          mem = ((env[:machine].provider_config.memory) * (1024*1024)).to_s

          env[:xc].call("VM.set_memory_limits",env[:session],vm_ref,mem,mem,mem,mem)
          env[:xc].call("VM.provision",env[:session],vm_ref)

          env[:machine].id = vm_ref

          @app.call env
        end
      end
    end
  end
end
