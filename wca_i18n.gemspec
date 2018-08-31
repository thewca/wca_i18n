
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "wca_i18n/version"

Gem::Specification.new do |spec|
  spec.name          = "wca_i18n"
  spec.version       = WcaI18n::VERSION
  spec.authors       = ["WCA Software Team"]
  spec.email         = ["software@worldcubeassociation.org"]

  spec.summary       = %q{Track how up to date Rails translations are.}
  spec.homepage      = "https://github.com/thewca/wca-i18n"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "byebug", "~> 9.0"
  spec.add_runtime_dependency "colorize", "~> 0.8"

  spec.required_ruby_version = '>= 2.5'
end
