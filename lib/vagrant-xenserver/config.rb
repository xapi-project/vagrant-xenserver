require "vagrant"

module VagrantPlugins
  module XenServer
    class Config < Vagrant.plugin("2", :config)
      # The XenServer host name or IP
      #
      # @return [String]
      attr_accessor :xs_host

      # The port to communicate with the API on XenServer
      #
      # @return [Int]
      attr_accessor :xs_port

      # True if the API should be accessed over SSL/TLS
      #
      # @return [Bool]
      attr_accessor :xs_use_ssl

      # The XenServer username
      #
      # @return [String]
      attr_accessor :xs_username

      # The XenServer password
      #
      # @return [String]
      attr_accessor :xs_password

      # Name of the VM
      #
      # @return [String]
      attr_accessor :name

      # True if the VM should be PV
      #
      # @return [Bool]
      attr_accessor :pv

      # Timeout for commands sent to XenServer
      #
      # @return [Int]
      attr_accessor :api_timeout

      # Memory settings
      #
      # @return [Int]
      attr_accessor :memory

      # template: If this is set, we'll use the template with this reference rather than downloading one or making a new one
      #
      # @return [String]
      attr_accessor :template

      # XVA URL: If this is set, we'll assume that the XenServer should directly download an XVA from the specified URL
      #
      # @return [String]
      attr_accessor :xva_url

      # Use HIMN: If this is set, we'll use the host-internal-management-network to connect to the VM (proxying via dom0)
      # Useful if the guest does not have tools installed
      attr_accessor :use_himn

      def initialize
        @xs_host = UNSET_VALUE
        @xs_port = UNSET_VALUE
        @xs_use_ssl = UNSET_VALUE
        @xs_username = UNSET_VALUE
        @xs_password = UNSET_VALUE
        @name = UNSET_VALUE
        @pv = UNSET_VALUE
        @api_timeout = UNSET_VALUE
        @template = UNSET_VALUE
        @memory = UNSET_VALUE
        @xva_url = UNSET_VALUE
        @use_himn = UNSET_VALUE
      end

      def finalize!
        @xs_host = nil if @xs_host == UNSET_VALUE
        @xs_port = 80 if @xs_port == UNSET_VALUE
        @xs_use_ssl = false if @xs_use_ssl == UNSET_VALUE
        @xs_username = nil if @xs_username == UNSET_VALUE
        @xs_password = nil if @xs_password == UNSET_VALUE
        @name = nil if @name == UNSET_VALUE
        @pv = nil if @pv == UNSET_VALUE
        @api_timeout = 60 if @api_timeout == UNSET_VALUE
        @memory = 1024 if @memory == UNSET_VALUE
        @template = nil if @template == UNSET_VALUE
        @xva_url = nil if @xva_url == UNSET_VALUE
        @use_himn = false if @use_himn == UNSET_VALUE
      end

      def validate(machine)
        errors = _detected_errors
        errors << I18n.t("vagrant_xenserver.config.host_required") if @xs_host.nil?
        errors << I18n.t("vagrant_xenserver.config.username_required") if @xs_username.nil?
        errors << I18n.t("vagrant_xenserver.config.password_required") if @xs_password.nil?

        if not (machine.config.vm.networks.any? { |type,options| type == :public_network })
          errors << I18n.t("vagrant_xenserver.config.himn_required") if not @use_himn
        end
        { "XenServer Provider" => errors }
      end
    end
  end
end

