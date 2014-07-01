require "vagrant"

module VagrantPlugins
  module XenServer
    class Provider < Vagrant.plugin("2", :provider)
      def initialize(machine)
        @machine = machine
      end

      def action(name)
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
        nil
      end

      def ssh_info
        env = @machine.action('read_ssh_info')
        env[:machine_ssh_info]
      end

      def state
        env = @machine.action("read_state")

        state_id = env[:machine_state_id]
        
        Vagrant::MachineState.new(state_id, state_id, state_id)
      end

      def to_s
        id = @machine.id.nil? ? "new" : @machine.id
        "XenServer (#{id})"
      end
    end
  end
end

