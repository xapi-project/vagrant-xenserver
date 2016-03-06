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
          #box_image_file = env[:machine].box.directory.join('export.xva').to_s
          box_image_file = "/home/jludlam/devel/vagrant-xenserver/test.xva"
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
            task_status = env[:xc].task.get_status(task)
          end while task_status == "pending"

          @logger.info("task_status="+task_status)

          if task_status != "success"
            raise Errors::APIError
          end

          task_result = env[:xc].task.get_result(task)

          doc = REXML::Document.new(task_result)

          doc.elements.each('value/array/data/value') do |ele|
            @logger.info("ele=" + ele.text)
          end

          @logger.info("task_result=" + task_result)

        end
      end
    end
  end
end
