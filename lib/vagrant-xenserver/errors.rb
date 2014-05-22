require "vagrant"

module VagrantPlugins
  module XenServer
    module Errors
      class VagrantXenServerError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_xenserver.errors")
      end
    end
  end
end

