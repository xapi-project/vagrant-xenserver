require "log4r"
require "xmlrpc/client"

module VagrantPlugins
  module XenServer
    module Action
      class ConnectXS
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant_xenserver::actions::connect_xs")
        end

        def call(env)
          if not env[:session]
            env[:xc] = XMLRPC::Client.new(env[:machine].provider_config.xs_host, "/", "80")
            
            @logger.info("Connecting to XenServer")
            
            sess_result = env[:xc].call("session.login_with_password", env[:machine].provider_config.xs_username, env[:machine].provider_config.xs_password,"1.0")
            
            if sess_result["Status"] != "Success"
              raise Errors::LoginError
            end
            
            env[:session] = sess_result["Value"]
          end

          @app.call(env)
        end
      end
    end
  end
end

