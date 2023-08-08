# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rb_banyan/version"

Gem::Specification.new do |spec|
  spec.name = "rb_banyan"
  spec.version = RbBanyan::VERSION
  spec.authors = ["Alan Yorinks"]
  spec.email = ["MrYsLab@gmail.com"]
  spec.licenses = ['AGPL-3.0']
  spec.summary = %q{BanyanBase is the base class used to derive Banyan compatible components.}
  spec.description = %q{This gem contains the base class used to create Banyan compatible components
                          requiring connection to a single Banyan backplane. In addition to the base class,
                          executables for rb_backplane and rb_monitor are installed on the executable
                          path.}
  spec.homepage = "https://github.com/MrYsLab/rb_banyan"
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) {|f| File.basename(f)}
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency('ffi-rzmq', '~> 2.0')
  spec.add_runtime_dependency('msgpack', '~> 1.1')

  spec.add_development_dependency "bundler", "~> 2.2.33"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
