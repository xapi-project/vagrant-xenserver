require 'vagrant/action/builder'
require 'log4r'

module VagrantPlugins
  module XenServer
    module Action
      include Vagrant::Action::Builtin
      @logger = Log4r::Logger.new('vagrant::xenserver::action')

      def self.action_up
	Vagrant::Action::Builder.new.tap do |b|
          b.use HandleBox
          b.use ConfigValidate
          b.use ConnectXS
          b.use Call, IsCreated do |env,b2|
            # Create the VM
            if !env[:result]
              b2.use UploadVHD
              b2.use CloneDisk
              b2.use CreateVM
              b2.use Provision
              b2.use PrepareNFSValidIds
              b2.use SyncedFolderCleanup
              b2.use SyncedFolders
              b2.use StartVM
              b2.use WaitForCommunicator, ["Running"]
              b2.use PrepareNFSSettings

            end
          end
        end
      end

      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              @logger.info "MessageNotCreated"
              next
            end
            
            b2.use ConnectXS
            b2.use DestroyVM
          end
        end
      end

      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectXS
          b.use ReadState
        end
      end

      def self.action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectXS
          b.use ReadSSHInfo
        end
      end

      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          @logger.info("XXXXX SSH")
          b.use ConfigValidate
          b.use Call, IsCreated do | env, b2|
            if !env[:result]
#              b2.use MessageNotCreated
              @logger.info("MessageNotCreate")
              next
            end

            b2.use ConnectXS
            b2.use Call, IsRunning do |env2, b3|
              if !env2[:result]
                #b3.use MessageNotRunning
                @logger.info("MessageNotCreate")
                next
              end

              b3.use SSHExec
              @logger.info("ssh run")
            end
          end
        end
      end

      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          @logger.info("XXXXX SSH")
          b.use ConfigValidate
          b.use Call, IsCreated do | env, b2|
            if !env[:result]
#              b2.use MessageNotCreated
              @logger.info("MessageNotCreate")
              next
            end

            b2.use ConnectXS
            b2.use Call, IsRunning do |env2, b3|
              if !env2[:result]
                #b3.use MessageNotRunning
                @logger.info("MessageNotCreate")
                next
              end

              b3.use SSHRun
              @logger.info("ssh run")
            end
          end
        end
      end

      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          @logger.info("XXXXX provision")
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              @logger.info("MessageNotCreated")
              next
            end

            b2.use ConnectXS
            b2.use Call, IsRunning do |env2, b3|
              if !env2[:result]
                @logger.info("MessageNotRunning")
                next
              end

              b3.use Provision
            end
          end
        end
      end

      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :ConnectXS, action_root.join("connect_xs")
      autoload :DummyMessage, action_root.join('dummy')
      autoload :ReadState, action_root.join('read_state')
      autoload :IsCreated, action_root.join('is_created')
      autoload :IsRunning, action_root.join('is_running')
      autoload :UploadXVA, action_root.join('upload_xva')
      autoload :UploadVHD, action_root.join('upload_vhd')
      autoload :CloneDisk, action_root.join('clone_disk')
      autoload :CreateVM, action_root.join('create_vm')
      autoload :DestroyVM, action_root.join('destroy_vm')
      autoload :StartVM, action_root.join('start_vm')
      autoload :ReadSSHInfo, action_root.join('read_ssh_info')
      autoload :PrepareNFSSettings, action_root.join('prepare_nfs_settings')
      autoload :PrepareNFSValidIds, action_root.join('prepare_nfs_valid_ids')
    end
  end
end

