# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sonos/version'

Gem::Specification.new do |gem|
  gem.name          = 'sonos'
  gem.version       = Sonos::VERSION
  gem.authors       = ['Sam Soffes', 'Aaron Gotwalt', 'Jasper Lievisse Adriaanse']
  gem.email         = ['sam@soff.es', 'gotwalt@gmail.com', 'jasper@humppa.nl']
  gem.description   = 'Control Sonos speakers with Ruby'
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/soffes/sonos'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 1.9.2'
  gem.add_dependency 'savon', '~> 2.0'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'thor'
  gem.add_dependency 'httpclient'
  gem.add_dependency 'ssdp'
end
