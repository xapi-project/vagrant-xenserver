require "vagrant"

module VagrantPlugins
  module AWS
    class Config < Vagrant.plugin("2", :config)
      attr_accessor :dummy
      
      def initialize
        @dummy = UNSET_VALUE
      end

      def finalize!
        @dummy = 0 if @dummy == UNSET_VALUE
      end
    end
  end
end
