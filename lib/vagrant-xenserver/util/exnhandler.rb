# Handle the errors thrown by XenServer
require "json"

module VagrantPlugins
  module XenServer
    module MyUtil
      class Exnhandler

        def self.def(api,error)
          # Default case: raise generic API error
          raise Errors::APIError,
                api: api,
                error: String(error)
        end

        def self.handle(api,error)
          case error[0]
          when "IMPORT_ERROR"
            case error[1]
            when "404 Not Found"
              raise Errors::Import404
            else
              Exnhandler.def(api,error)
            end
          when "SR_BACKEND_FAILURE_44"
            raise Errors::InsufficientSpace
          else
            raise Errors::APIError,
                  api: api,
                  error: String(error)
          end
        end

        def self.handle_xenapiexn(api,e,logger)
          case e
          when XenApi::Errors::SRFull
            raise Errors::InsufficientSpace
          when XenApi::Errors::GenericError
            # Grotesque hack - get the error array back by parsing the string
            # representation as JSON. Bleurgh!
            self.handle(api,JSON.parse(e.message))
          else
            self.handle(api,e)
          end
        end
      end
    end
  end
end
