require "log4r"
require "xmlrpc/client"

module VagrantPlugins
  module XenServer
    module Action
      class DestroyVM
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::destroy_vm")
        end
        
        def call(env)
          env[:xc].call("VM.hard_shutdown",env[:session],env[:machine].id)
          
          vbds = env[:xc].call("VM.get_VBDs",env[:session],env[:machine].id)['Value']
          
          vbds.each { |vbd| 
            vbd_rec = env[:xc].call("VBD.get_record",env[:session],vbd)['Value']
            if vbd_rec['type'] == "Disk"
              env[:xc].call("VDI.destroy",env[:session],vbd_rec['VDI'])
            end
          }

          env[:xc].call("VM.destroy",env[:session],env[:machine].id)

          env[:machine].id = nil

          @app.call env
        end
      end
    end
  end
end
