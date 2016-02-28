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
            config = env[:machine].provider_config
            env[:xc] = XMLRPC::Client.new3({
              'host' => config.xs_host,
              'path' => "/",
              'port' => config.xs_port,
              'use_ssl' => config.xs_use_ssl
            })
            env[:xc].timeout = config.api_timeout unless config.api_timeout.nil?
            
            @logger.info("Connecting to XenServer")
            sess_result = env[:xc].call("session.login_with_password", config.xs_username, config.xs_password,"1.0")
            
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

