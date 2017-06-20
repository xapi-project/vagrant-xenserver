require "log4r"
require "xenapi"
require "uri"

module VagrantPlugins
  module XenServer
    module Action
      class ConnectXS
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::connect_xs")
        end

        def call(env)
          config = env[:machine].provider_config

          # Only even try to connect if we've got a hostname
          if (not env[:xc]) && (not config.xs_host.nil?)
            uri = URI::Generic.new(config.xs_use_ssl ? 'https' : 'http',
                              nil,
                              config.xs_host,
                              config.xs_port,
                              nil,
                              "/",
                              nil,
                              nil, nil)
            env[:xc] = XenApi::Client.new(uri.to_s, timeout = config.api_timeout)

            @logger.info("Connecting to XenServer")

            begin
              result = env[:xc].login_with_password(config.xs_username, config.xs_password)
            rescue XenApi::Errors::SessionAuthenticationFailed
              raise Errors::LoginError
            rescue
              raise Errors::ConnectionError
            end

            @logger.info("Connected to XenServer")
          end

          @app.call(env)
        end
      end
    end
  end
end
