require "pathname"

require "vagrant-xenserver/plugin"

module VagrantPlugins
  module XenServer
    lib_path = Pathname.new(File.expand_path("../vagrant-xenserver", __FILE__))
    autoload :Action, lib_path.join("action")
    autoload :Errors, lib_path.join("errors")

    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
    end
  end
end

