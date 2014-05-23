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

    end
  end
end

