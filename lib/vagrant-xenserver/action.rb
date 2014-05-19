require 'vagrant/action/builder'
require 'log4r'

module VagrantPlugins
  module XenServer
    module Action
      include Vagrant::Action::Builtin
      @logger = Log4r::Logger.new('vagrant_xenserver::action')

      def self.action_up
	Vagrant::Action::Builder.new.tap do |b|
          b.use DummyMessage
        end
      end

      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :DummyMessage, action_root.join('dummy')
    end
  end
end

