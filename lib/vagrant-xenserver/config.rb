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

      # Memory settings
      #
      # @return [Int]
      attr_accessor :memory

      def initialize
        @xs_host = UNSET_VALUE
        @xs_port = UNSET_VALUE
        @xs_use_ssl = UNSET_VALUE
        @xs_username = UNSET_VALUE
        @xs_password = UNSET_VALUE
        @name = UNSET_VALUE
        @pv = UNSET_VALUE
        @memory = UNSET_VALUE
	@xva_url = UNSET_VALUE
      end

      def finalize!
        @xs_host = nil if @xs_host == UNSET_VALUE
        @xs_port = 80 if @xs_port == UNSET_VALUE
        @xs_use_ssl = false if @xs_use_ssl == UNSET_VALUE
        @xs_username = nil if @xs_username == UNSET_VALUE
        @xs_password = nil if @xs_password == UNSET_VALUE
        @name = nil if @name == UNSET_VALUE
        @pv = nil if @pv == UNSET_VALUE
        @memory = 1024 if @memory == UNSET_VALUE
	@xva_url = nil if @xva_url = UNSET_VALUE
      end

      def validate(machine)
        errors = _detected_errors
        errors << I18n.t("vagrant_xenserver.config.host_required") if @xs_host.nil?
        errors << I18n.t("vagrant_xenserver.config.username_required") if @xs_username.nil?
        errors << I18n.t("vagrant_xenserver.config.password_required") if @xs_password.nil?

        { "XenServer Provider" => errors }
      end
    end
  end
end
