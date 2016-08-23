require "log4r"
require "xmlrpc/client"
require "vagrant-xenserver/util/uploader"
require "rexml/document"

module VagrantPlugins
  module XenServer
    module Action
      class UploadXVA
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::upload_xva")
        end

        def call(env)
          box_name = env[:machine].box.name.to_s
          box_version = env[:machine].box.version.to_s

          templates = env[:xc].VM.get_all_records_where("field \"is_a_template\"=\"true\"")
          template = templates.detect { |vm,vmr|
            vmr["other_config"]["box_name"] == box_name &&
              vmr["other_config"]["box_version"] == box_version
          }

          box_xva_file = env[:machine].box.directory.join('box.xva').to_s

          if File.exist?(box_xva_file) && template.nil?
            #box_image_file = env[:machine].box.directory.join('export.xva').to_s
            hostname = env[:machine].provider_config.xs_host
            session = env[:session]

            @logger.info("box name=" + env[:machine].box.name.to_s)
            @logger.info("box version=" + env[:machine].box.version.to_s)

            # Create a task to so we can get the result of the upload
            task = env[:xc].task.create("vagrant-xva-upload",
                                        "Task to track progress of the XVA upload from vagrant")

            url = "https://#{hostname}/import?session_id=#{env[:xc].xenapi_session}&task_id=#{task}"

            uploader_options = {}
            uploader_options[:ui] = env[:ui]
            uploader_options[:insecure] = true

            uploader = MyUtil::Uploader.new(box_xva_file, url, uploader_options)

            begin
              uploader.upload!
            rescue
              env[:xc].task.cancel(task)
            end

            task_status = ""

            begin
              sleep(0.2)
              task_status = env[:xc].task.get_status(task)
            end while task_status == "pending"

            if task_status != "success"
	      # Task failed - let's find out why:
	      error_list = env[:xc].task.get_error_info(task)
              MyUtil::Exnhandler.handle("VM.import", error_list)
            end

            task_result = env[:xc].task.get_result(task)

            doc = REXML::Document.new(task_result)

            @logger.debug("task_result=\"#{task_result}\"")
            template_ref = doc.elements['value/array/data/value'].text

            @logger.info("template_ref=" + template_ref)

            # Make sure it's really a template, and add the xva_url to other_config:
            env[:xc].VM.set_is_a_template(template_ref,true)
            env[:xc].VM.add_to_other_config(template_ref,"box_name",box_name)
            env[:xc].VM.add_to_other_config(template_ref,"box_version",box_version)   

            # Hackity hack: HVM booting guests don't need to set the bootable flag
            # on their VBDs, but PV do. Let's set bootable=true on VBD device=0
            # just in case.

            vbds = env[:xc].VM.get_VBDs(template_ref)
            vbds.each { |vbd|
              if env[:xc].VBD.get_userdevice(vbd) == "0"
                env[:xc].VBD.set_bootable(vbd, true)
              end
            }
            env[:template] = template_ref
          end

          @app.call(env)
        end
      end
    end
  end
end
