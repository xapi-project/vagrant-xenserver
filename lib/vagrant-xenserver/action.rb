require 'vagrant/action/builder'
require 'log4r'

module VagrantPlugins
  module XenServer
    module Action
      include Vagrant::Action::Builtin
      @logger = Log4r::Logger.new('vagrant_xenserver::action')

      def self.action_up
	Vagrant::Action::Builder.new.tap do |b|
          b.use HandleBox
          b.use ConfigValidate
          b.use ConnectXS
          b.use DummyMessage
        end
      end

      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectXS
          b.use ReadState
        end
      end

      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :ConnectXS, action_root.join("connect_xs")
      autoload :DummyMessage, action_root.join('dummy')
      autoload :ReadState, action_root.join('read_state')
      autoload :IsCreated, action_root.join('is_created')

    end
  end
end

