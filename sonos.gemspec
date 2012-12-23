# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sonos/version'

Gem::Specification.new do |gem|
  gem.name          = 'sonos'
  gem.version       = Sonos::VERSION
  gem.authors       = ['Sam Soffes']
  gem.email         = ['sam@soff.es']
  gem.description   = 'Sonos Controller'
  gem.summary       = 'Control Sonos speakers with Ruby'
  gem.homepage      = 'https://github.com/soffes/sonos'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'savon', '~> 2.0.2'
end
