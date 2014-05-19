require "vagrant"

module VagrantPlugins
  module AWS
    module Errors
      class VagrantXenServerError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_xenserver.errors")
      end
    end
  end
end

