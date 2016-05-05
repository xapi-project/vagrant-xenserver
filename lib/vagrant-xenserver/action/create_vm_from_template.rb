require "log4r"
require "xmlrpc/client"
require "vagrant-xenserver/util/uploader"
require "rexml/document"
require "json"
require "etc"

module VagrantPlugins
  module XenServer
    module Action
      class CreateVMFromTemplate
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::create_vm_from_template")
        end
        
        def call(env, box_name, box_version, vm_name)
          
          template_ref = env[:xc].call("VM.get_by_name_label",env[:session],"#{box_name}/#{box_version}")['Value'][0]
          @logger.info("Template: #{template_ref}")

          #Only continue if we found a match
          if template_ref
            @logger.info("Creating VM as #{vm_name}")
            vm_ref = env[:xc].call("VM.clone",env[:session],template_ref,vm_name)['Value']
            @logger.info("VM: #{vm_ref}")
            
            return vm_ref
          else
            @logger.error("Unable to find the imported template (#{box_name}/#{box_version}) for cloning!")
            raise Vagrant::Errors::VMNoMatchError
          end
        end
      end
    end
  end
end
