require 'vagrant/action/builder'
require 'log4r'

module VagrantPlugins
  module XenServer
    module Action
      include Vagrant::Action::Builtin
      @logger = Log4r::Logger.new('vagrant::xenserver::action')

      def self.action_boot
	Vagrant::Action::Builder.new.tap do |b| 
          b.use Provision
          b.use PrepareNFSValidIds
          b.use SyncedFolderCleanup
          b.use SyncedFolders
          b.use StartVM
          b.use WaitForCommunicator, ["Running"]
          b.use PrepareNFSSettings         
        end
      end
      
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
              b2.use CreateVIFs
            end
            b2.use action_boot
          end
        end
      end
      
      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              @logger.info "MessageNotCreated"
              next
            end
            b2.use ConnectXS
            b2.use Call, IsRunning do |env, b3|
              if !env[:result]
                @logger.info "Not running"
                next
              end
              b3.use HaltVM            
            end
          end
        end
      end

      def self.action_suspend
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              @logger.info "MessageNotCreated"
              next
            end
            b2.use ConnectXS
            b2.use Call, IsRunning do |env, b3|
              if !env[:result]
                @logger.info "Not running"
                next
              end
              b3.use SuspendVM
            end
          end
        end
      end

      def self.action_resume
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              @logger.info "MessageNotCreated"
              next
            end
            b2.use ConnectXS
            b2.use Call, IsSuspended do |env, b3|
              if !env[:result]
                @logger.info "Not suspended"
                next
              end
              b3.use ResumeVM
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
            b2.use ProvisionerCleanup
            b2.use PrepareNFSValidIds
            b2.use SyncedFolderCleanup
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

      def self.action_reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, IsCreated do |env1, b2|
            if !env1[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use ConfigValidate
            b2.use action_halt
            b2.use action_boot
          end
        end
      end

      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :CreateVIFs, action_root.join("create_vifs")
      autoload :ConnectXS, action_root.join("connect_xs")
      autoload :DummyMessage, action_root.join('dummy')
      autoload :ReadState, action_root.join('read_state')
      autoload :IsCreated, action_root.join('is_created')
      autoload :IsRunning, action_root.join('is_running')
      autoload :IsSuspended, action_root.join('is_suspended')
      autoload :UploadXVA, action_root.join('upload_xva')
      autoload :UploadVHD, action_root.join('upload_vhd')
      autoload :CloneDisk, action_root.join('clone_disk')
      autoload :CreateVM, action_root.join('create_vm')
      autoload :DestroyVM, action_root.join('destroy_vm')
      autoload :StartVM, action_root.join('start_vm')
      autoload :HaltVM, action_root.join('halt_vm')
      autoload :SuspendVM, action_root.join('suspend_vm')
      autoload :ResumeVM, action_root.join('resume_vm')
      autoload :ReadSSHInfo, action_root.join('read_ssh_info')
      autoload :PrepareNFSSettings, action_root.join('prepare_nfs_settings')
      autoload :PrepareNFSValidIds, action_root.join('prepare_nfs_valid_ids')
    end
  end
end

