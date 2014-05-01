# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xo/version'

Gem::Specification.new do |spec|
  spec.name          = 'xo'
  spec.version       = XO::VERSION
  spec.author        = 'Dwayne R. Crooks'
  spec.email         = ['me@dwaynecrooks.com']
  spec.summary       = %q{A Ruby library for Tic-tac-toe.}
  spec.description   = %q{A Ruby library that can be used to develop Tic-tac-toe game clients.}
  spec.homepage      = 'https://github.com/dwayne/xo'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'coveralls'

  # For documentation
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'yard'
end
