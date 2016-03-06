module VagrantPlugins
  module XenServer
    module Action
      class PrepareNFSValidIds
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::action::vm::nfs")
        end

        def call(env)
          env[:nfs_valid_ids] = env[:xc].VM.get_all
          @app.call(env)
        end
      end
    end
  end
end
