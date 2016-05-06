require "vagrant"

module VagrantPlugins
  module XenServer
    module Errors
      class VagrantXenServerError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_xenserver.errors")
      end

      class LoginError < VagrantXenServerError
        error_key(:login_error)
      end

      class UploaderInterrupted < VagrantXenServerError
        error_key(:uploader_interrupted)
      end

      class UploaderError < VagrantXenServerError
        error_key(:uploader_error)
      end

      class APIError < VagrantXenServerError
        error_key(:api_error)
      end

      class UnknownOS < VagrantXenServerError
        error_key(:unknown_os)
      end

      class QemuImgError < VagrantXenServerError
        error_key(:qemuimg_error)
      end

      class NoDefaultSR < VagrantXenServerError
        error_key(:nodefaultsr_error)
      end

      class NoHostsAvailable < VagrantXenServerError
        error_key(:nohostsavailable_error)
      end
    end
  end
end

