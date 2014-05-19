require "vagrant"

module VagrantPlugins
  module XenServer
    class Provider < Vagrant.plugin("2", :provider)
      def initialize(machine)
        @machine = machine
      end

      def action(name)
        nil
      end

      def ssh_info
        return nil
      end

      def state
        return nil
      end

      def to_s
        return nil
      end
    end
  end
end

