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
#          b.use Call, IsCreated do |env,b2|
            # Create the VM
#            if !env[:result]
#              b2.use MaybeUploadDisk
#              b2.use CloneDisk
#              b2.use CreateVM
#              b2.use CreateNetworks
#              b2.use PrepareNFSValidIds
#              b2.use SyncedFolderCleanup
#              b2.use SyncedFolders

#              b2.use StartVM
#              b2.use WaitTillUp

#              b2.use ForwardPorts
#              b2.use PrepareNFSSettings
#              b2.use ShareFolders
#              b2.use SetHostname
              

          b.use UploadXVA
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
      autoload :UploadXVA, action_root.join('upload_xva')
    end
  end
end

