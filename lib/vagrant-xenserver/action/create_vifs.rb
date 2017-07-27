require "log4r"
require "xmlrpc/client"

module VagrantPlugins
  module XenServer
    module Action
      class CreateVIFs
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::xenserver::actions::create_vifs")
        end

        def create_vif(env, vm, network, mac)
          vif_devices = env[:xc].VM.get_allowed_VIF_devices(vm)

          vif_record = {
            'VM' => vm,
            'network' => network,
            'device' => vif_devices[0],
            'MAC' => mac,
            'MTU' => '1500',
            'other_config' => {},
            'qos_algorithm_type' => '',
            'qos_algorithm_params' => {},
            'locking_mode' => 'network_default',
            'ipv4_allowed' => [],
            'ipv6_allowed' => []
          }

          vif_res = env[:xc].VIF.create(vif_record)

          return vif_res
        end

        def call(env)
          vm_ref = env[:machine].id

          networks = env[:xc].network.get_all_records

          # Remove all current VIFs
          current_vifs = env[:xc].VM.get_VIFs(vm_ref)
          current_vifs.each { |vif| env[:xc].VIF.destroy(vif) }

          # If a HIMN VIF has been asked for, create one
          if env[:machine].provider_config.use_himn
            himn = networks.find { |ref,net| net['other_config']['is_host_internal_management_network'] }
            (himn_ref,himn_rec) = himn

            @logger.debug("himn="+himn.to_s)

            create_vif(env, vm_ref, himn_ref, '')
          end


          env[:machine].config.vm.networks.each do |type, options|
            @logger.info "got an interface: #{type} #{options}"

            if type == :public_network then
              bridge = options[:bridge]
              mac = options[:mac] || ''

              netrefrec = networks.find { |ref,net| net['bridge']==bridge }
              (net_ref,net_rec) = netrefrec
              if net_ref.nil? then
                  @logger.error("Error finding bridge #{bridge} on host")
                  raise Errors::NoHostsAvailable
              end

              vif_res = create_vif(env, vm_ref, net_ref, mac)

              @logger.info("vif_res=" + vif_res.to_s)
            end
          end

          @app.call env
        end
      end
    end
  end
end
