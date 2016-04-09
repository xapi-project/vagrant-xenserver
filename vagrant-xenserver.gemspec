$:.unshift File.expand_path("../lib", __FILE__)
require "vagrant-xenserver/version"

Gem::Specification.new do |s|
  s.name          = "vagrant-xenserver"
  s.version       = VagrantPlugins::XenServer::VERSION
  s.platform      = Gem::Platform::RUBY
  s.license       = "MIT"
  s.authors       = "Jon Ludlam"
  s.email         = "jonathan.ludlam@citrix.com"
  s.homepage      = "http://github.com/jonludlam/vagrant-xenserver"
  s.summary       = "Enables Vagrant to manage XenServers."
  s.description   = "Enables Vagrant to manage XenServers."

  s.add_development_dependency "rake"
  s.add_runtime_dependency "json"

  s.files         = `git ls-files`.split($\)
  s.executables   = [] # gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = [] #gem.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

end
