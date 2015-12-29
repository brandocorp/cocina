# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocina/version'

Gem::Specification.new do |spec|
  spec.name          = 'cocina'
  spec.version       = Cocina::VERSION
  spec.authors       = ['Brandon Raabe']
  spec.email         = ['brandocorp+cochina@gmail.com']

  spec.summary       = 'Test Kitchen with Dependencies'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/brandocorp/cocina'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'

  spec.add_dependency 'berkshelf', '~> 4.0.1'
  spec.add_dependency 'test-kitchen', '~> 1.4.2'
  spec.add_dependency 'kitchen-vagrant', '~> 0.19.0'
end
