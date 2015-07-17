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
        
        def call(env)
          myvm = env[:machine].id

          env[:machine].config.vm.networks.each do |type, options|
            next if type == :forwarded_port
            @logger.info "got an interface: #{type} #{options}"

            if type == :public_network then
              bridge = options[:bridge]

              networks = env[:xc].call("network.get_all_records",env[:session])['Value']

              netrefrec = networks.find { |ref,net| net['bridge']==bridge }
              (net_ref,net_rec) = netrefrec

              vif_devices = env[:xc].call("VM.get_allowed_VIF_devices",env[:session],myvm)['Value']
              
              vif_record = {
                'VM' => myvm,
                'network' => net_ref,
                'device' => vif_devices[0],
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
            end
          end

          @app.call env
        end
      end
    end
  end
end
