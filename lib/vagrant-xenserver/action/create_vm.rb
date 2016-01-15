require "log4r"
require "xmlrpc/client"
require "vagrant-xenserver/util/uploader"
require "rexml/document"
require "json"
require "etc"

module VagrantPlugins
  module XenServer
    module Action
      class CreateVM
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::create_vm")
        end
        
        def call(env)
          vdi_ref = env[:my_vdi]
          
          networks = env[:xc].call("network.get_all_records",env[:session])['Value']

          himn = networks.find { |ref,net| net['other_config']['is_host_internal_management_network'] }
          (himn_ref,himn_rec) = himn

          @logger.info("himn_uuid="+himn_rec['uuid'])
          
          username = Etc.getlogin
          
          oim = env[:xc].call("VM.get_by_name_label",env[:session],"Other install media")['Value'][0]

          box_name = env[:machine].box.name.to_s
          box_version = env[:machine].box.version.to_s

          if env[:machine].provider_config.name.nil?
            vm_name = "#{username}/#{box_name}/#{box_version}"
          else
            vm_name = env[:machine].provider_config.name
          end

          vm_ref = env[:xc].call("VM.clone",env[:session],oim,vm_name)['Value']

          vbd_record = {
            'VM' => vm_ref,
            'VDI' => env[:my_vdi],
            'userdevice' => '0',
            'bootable' => true,
            'mode' => 'RW',
            'type' => 'Disk',
            'unpluggable' => false,
            'empty' => false,
            'other_config' => {},
            'qos_algorithm_type' => '',
            'qos_algorithm_params' => {}
          }

          vbd_res = env[:xc].call("VBD.create",env[:session],vbd_record)
          
          @logger.info("vbd_res=" + vbd_res.to_s)

          vif_record = {
            'VM' => vm_ref,
            'network' => himn_ref,
            'device' => '0',
            'MAC' => '',
            'MTU' => '1500',
            'other_config' => {},
            'qos_algorithm_type' => '',
            'qos_algorithm_params' => {},
            'locking_mode' => 'network_default',
            'ipv4_allowed' => [],
            'ipv6_allowed' => []
          }

          vif_res = env[:xc].call("VIF.create",env[:session],vif_record)
          
          @logger.info("vif_res=" + vif_res.to_s)

          if env[:machine].provider_config.pv
            env[:xc].call("VM.set_HVM_boot_policy",env[:session],vm_ref,"")
            env[:xc].call("VM.set_PV_bootloader",env[:session],vm_ref,"pygrub")
          end

          mem = ((env[:machine].provider_config.memory) * (1024*1024)).to_s

          env[:xc].call("VM.set_memory_limits",env[:session],vm_ref,mem,mem,mem,mem)
          env[:xc].call("VM.provision",env[:session],vm_ref)

          env[:machine].id = vm_ref

          @app.call env
        end
      end
    end
  end
end
