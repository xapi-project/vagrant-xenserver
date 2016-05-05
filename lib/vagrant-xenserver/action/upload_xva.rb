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
          box_image_file = env[:machine].box.directory.join('export.xva').to_s
          hostname = env[:machine].provider_config.xs_host
          session = env[:session]
          box_name = env[:machine].box.name.to_s
          box_version = env[:machine].box.version.to_s
          
          @logger.info("box name=" + box_name)
          @logger.info("box version=" + box_version)
          
          # Find out if it has already been uploaded
          uploaded_name = "#{box_name}/#{box_version}"
          vm_list_ref = env[:xc].call("VM.get_all_records", env[:session])

          if vm_list_ref["Status"] != "Success"
            @logger.error ("Error getting vm records: " + vm_list_ref["ErrorDescription"].join(", "))
            raise Errors::UploadXVAError, {message: "Error getting vm records: " + vm_list_ref["ErrorDescription"].join(", ")}
          else
            vm_ref_rec = vm_list_ref["Value"].find { |reference,record|
              @logger.info("Found vm: " + record['name_label'].to_s)
              record['name_label'] == uploaded_name
            }
            
            if not vm_ref_rec
              # Didn't find it so we'll upload it
              
              # Create a task to so we can get the result of the upload
              task_result = env[:xc].call("task.create", env[:session], "vagrant-xva-upload",
                      "Task to track progress of the XVA upload from vagrant")
              
              if task_result["Status"] != "Success"
                raise Errors::APIError
              end
              
              task = task_result["Value"]
              
              url = "https://#{hostname}/import?session_id=#{session}&task_id=#{task}"
              
              uploader_options = {}
              uploader_options[:ui] = env[:ui]
              uploader_options[:insecure] = true
              
              uploader = MyUtil::Uploader.new(box_image_file, url, uploader_options)
              
              begin
                uploader.upload!
              rescue Errors::UploaderInterrupted
                env[:ui].info(I18n.t("vagrant.xenserver.action.upload_xva.interrupted"))
                raise
              end
              
              task_status = ""
              
              begin
                sleep(0.2)
                task_status_result = env[:xc].call("task.get_status",env[:session],task)
                if task_status_result["Status"] != "Success"
                  raise Errors::APIError
                end
                task_status = task_status_result["Value"]
              end while task_status == "pending"
              
              @logger.info("task_status="+task_status)
              
              if task_status != "success"
                raise Errors::APIError
              end
              
              task_result_result = env[:xc].call("task.get_result",env[:session],task)
              if task_result_result["Status"] != "Success"
                raise Errors::APIError
              end
              
              task_result = task_result_result["Value"]
              
              doc = REXML::Document.new(task_result)
              
              doc.elements.each('value/array/data/value') do |ele|
                @logger.info("ele=" + ele.text)
              end
            
              @logger.info("task_result=" + task_result)
            end
            
            @app.call(env)
          end
        end
      end
    end
  end
end
