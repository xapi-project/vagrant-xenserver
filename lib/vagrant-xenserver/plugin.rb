begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant XenServer plugin must be run within Vagrant."
end


module VagrantPlugins
  module XenServer
    class Plugin < Vagrant.plugin("2")
      name "XenServer provider"
      description <<-DESC
	This plugin installs a provider that allows Vagrant to manage
	virtual machines hosted on a XenServer.
      DESC

      config('xenserver', :provider) do
        require_relative "config"
        Config
      end

      provider('xenserver', parallel: true) do
        setup_i18n

	require_relative "provider"
        Provider
      end

      def self.setup_i18n
        I18n.load_path << File.expand_path('locales/en.yml',
                                           XenServer.source_root)
        I18n.reload!
      end
    end
  end
end

