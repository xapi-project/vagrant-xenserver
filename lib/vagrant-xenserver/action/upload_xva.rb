require "log4r"
require "xmlrpc/client"
require "vagrant-xenserver/util/uploader"

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
          box_image_file = "/home/jludlam/devel/vagrant-xenserver/example_box/centos.xva"
          hostname = env[:machine].provider_config.xs_host
          session = env[:session]

          @logger.info("box name=" + env[:machine].box.name.to_s)
          @logger.info("box version=" + env[:machine].box.version.to_s)
          url = "http://#{hostname}/import?session_id=#{session}" 

          uploader_options = {}
          uploader_options[:ui] = env[:ui]

          uploader = MyUtil::Uploader.new(box_image_file, url, uploader_options)

          begin
            uploader.upload!
          rescue Errors::UploaderInterrupted
            env[:ui].info(I18n.t("vagrant.xenserver.action.upload_xva.interrupted"))
            raise
          end

        end
      end
    end
  end
end
