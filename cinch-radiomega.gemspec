# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cinch/plugins/radiomega/version'

Gem::Specification.new do |spec|
  spec.name          = 'cinch-radiomega'
  spec.version       = Cinch::Plugins::Radiomega::VERSION
  spec.authors       = ['Brian Haberer']
  spec.email         = ['bhaberer@gmail.com']
  spec.description   = %q{Write a gem description}
  spec.summary       = %q{Write a gem summary}
  spec.homepage      = 'http://github.com/bhaberer/cinch-radiomega/'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'coveralls', '~> 0.7'
  spec.add_development_dependency 'cinch-test', '~> 0.1', '>= 0.1.0'
  spec.add_dependency 'cinch', '~> 2'
  spec.add_dependency 'cinch-toolbox', '~> 1.1'
  spec.add_dependency 'jist', '~> 1.5'
end
