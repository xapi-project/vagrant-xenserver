require "vagrant"

module VagrantPlugins
  module XenServer
    class Config < Vagrant.plugin("2", :config)
      # The XenServer host name or IP
      #
      # @return [String]
      attr_accessor :xs_host

      # The XenServer username
      #
      # @return [String]
      attr_accessor :xs_username

      # The XenServer password
      #
      # @return [String]
      attr_accessor :xs_password

      # True if the VM should be PV
      #
      # @return [Bool]
      attr_accessor :pv

      # Memory settings
      #
      # @return [Int]
      attr_accessor :memory

      # Box type; box can be either vhd or xva
      #
      # @return [String]
      attr_accessor :box_type

      def initialize
        @xs_host = UNSET_VALUE
        @xs_username = UNSET_VALUE
        @xs_password = UNSET_VALUE
        @pv = UNSET_VALUE
        @memory = UNSET_VALUE
        @box_type = UNSET_VALUE
      end

      def finalize!
        @xs_host = nil if @xs_host == UNSET_VALUE
        @xs_username = nil if @xs_username == UNSET_VALUE
        @xs_password = nil if @xs_password == UNSET_VALUE
        @pv = nil if @pv == UNSET_VALUE
        @memory = 1024 if @memory == UNSET_VALUE
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
