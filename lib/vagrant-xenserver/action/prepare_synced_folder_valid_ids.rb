module VagrantPlugins
  module XenServer
    module Action
      class PrepareSyncedFolderValidIds
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::action::vm::synced_folders")
        end

        def call(env)
          #vm_references = env[:xc].call("VM.get_all_records",env[:session])['Value']
          vm_references = env[:xc].call("VM.get_all",env[:session])['Value']
          @logger.debug("#{vm_references.count} vms to consider")
          #env[:nfs_valid_ids] = Array.new(vm_references.count){|index|
          #  vm_references.values[index]['name_label']
          #}
          env[:nfs_valid_ids] = vm_references
          env[:smb_valid_ids] = env[:nfs_valid_ids]
          @app.call(env)
        end
      end
    end
  end
end
