begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant XenServer plugin must be run within Vagrant."
end

module VagrantPlugins
  module XenServer
    class Plugin < Vagrant.plugin("2")
      name "XenServer provider"
#      description <<-DESC
#	This plugin installs a provider that allows Vagrant to manage
#	virtual machines hosted on a XenServer.
#     DESC

#      config(:xs, :provider) do
#        require_relative "config"
#        Config
#      end
#
#      provider(:xs) do
#	require_relative "provider"
#        Provider
#      end
    end
  end
end

