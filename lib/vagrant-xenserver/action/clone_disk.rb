require "log4r"
require "xmlrpc/client"
require "vagrant-xenserver/util/uploader"
require "rexml/document"
require "json"

module VagrantPlugins
  module XenServer
    module Action
      class CloneDisk
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::upload_xva")
        end
        
        def call(env)
          vdi_ref = env[:box_vdi]

          clone = env[:xc].call("VDI.clone", env[:session], vdi_ref, {})['Value']

          env[:my_vdi] = clone

          @logger.info("clone VDI="+clone)

          @app.call(env)
        end
      end
    end
  end
end
