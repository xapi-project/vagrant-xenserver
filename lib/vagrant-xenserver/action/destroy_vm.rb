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
          begin
            env[:xc].VM.hard_shutdown(env[:machine].id)
          rescue
          end

          vbds = env[:xc].VM.get_VBDs(env[:machine].id)
          
          vbds.each { |vbd| 
            vbd_rec = env[:xc].VBD.get_record(vbd)
            if vbd_rec['type'] == "Disk"
              env[:xc].VDI.destroy(vbd_rec['VDI'])
            end
          }

          env[:xc].VM.destroy(env[:machine].id)

          env[:machine].id = nil

          @app.call env
        end
      end
    end
  end
end
