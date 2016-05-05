require "log4r"

module VagrantPlugins
  module XenServer
    module Cap
      module WinRM
      # Reads the WinRM forwarded port that currently exists on the machine
      # itself. This raises an exception if the machine isn't running.
      # @return [Hash<Integer>, Integer] Host => Guest port mappings
      def self.winrm_info(machine)
          env = machine.action('read_ssh_info')
          env[:machine_ssh_info]
      end
    end
  end
end
