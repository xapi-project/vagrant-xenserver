require "log4r"
require "xmlrpc/client"
require "vagrant-xenserver/util/uploader"
require "rexml/document"
require "json"
require "etc"

module VagrantPlugins
  module XenServer
    module Action
      class CreateTemplate
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::create_template")
        end
        
        def call(env)
          if env[:template].nil?

            box_name = env[:machine].box.name.to_s
            box_version = env[:machine].box.version.to_s

            # No template - that means it wasn't a downloaded XVA.
            # Let's create a VM and attach the uploaded VDI to it.
            # First see if we've done that already:
            
            templates = env[:xc].VM.get_all_records_where("field \"is_a_template\"=\"true\"")
            template = templates.detect { |vm,vmr|
              vmr["other_config"]["box_name"] == box_name &&
                vmr["other_config"]["box_version"] == box_version
            }

            if template.nil?
              vdi_ref = env[:box_vdi]

              oim = env[:xc].VM.get_by_name_label("Other install media")[0]
              
              template_name = "#{box_name}.#{box_version}"
              
              template_ref = env[:xc].VM.clone(oim,template_name)
              
              vbd_record = {
                'VM' => template_ref,
                'VDI' => env[:box_vdi],
                'userdevice' => '0',
                'bootable' => true,
                'mode' => 'RW',
                'type' => 'Disk',
                'unpluggable' => false,
                'empty' => false,
                'other_config' => {},
                'qos_algorithm_type' => '',
                'qos_algorithm_params' => {}
              }
              
              vbd_res = env[:xc].VBD.create(vbd_record)
              
              @logger.info("vbd_res=" + vbd_res.to_s)

              env[:xc].VM.add_to_other_config(template_ref, "box_name", box_name)
              env[:xc].VM.add_to_other_config(template_ref, "box_version", box_version)
              
              if env[:machine].provider_config.pv
                env[:xc].VM.set_HVM_boot_policy(template_ref,"")
                env[:xc].VM.set_PV_bootloader(template_ref,"pygrub")
              end

              mem = ((env[:machine].provider_config.memory) * (1024*1024)).to_s
              env[:xc].VM.set_memory_limits(template_ref,mem,mem,mem,mem)

              env[:template] = template_ref
              
            else
              @logger.info("Found pre-existing template for this box")
              (template_ref, template_rec) = template
              env[:template] = template_ref
            end
            
          end
            
          @app.call env
        end
      end
    end
  end
end
