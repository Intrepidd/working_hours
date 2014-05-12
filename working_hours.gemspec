# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'working_hours/version'

Gem::Specification.new do |spec|
  spec.name          = "working_hours"
  spec.version       = WorkingHours::VERSION
  spec.authors       = ["Intrepidd"]
  spec.email         = ["adrien@siami.fr"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_development_dependency 'rspec', '~> 2.14'
  spec.add_development_dependency 'activesupport', '~> 4.1'
end
