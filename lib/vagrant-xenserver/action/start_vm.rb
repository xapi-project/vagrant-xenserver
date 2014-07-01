require "log4r"
require "xmlrpc/client"
require "vagrant-xenserver/util/uploader"
require "rexml/document"
require "json"

module VagrantPlugins
  module XenServer
    module Action
      class StartVM
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::start_vm")
        end
        
        def call(env)
          myvm = env[:machine].id
          
          env[:xc].call("VM.start",env[:session],myvm,false,false)

          @app.call env
        end
      end
    end
  end
end
