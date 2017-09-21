# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bankscrap/version'

Gem::Specification.new do |spec|
  spec.name          = 'bankscrap'
  spec.version       = Bankscrap::VERSION
  spec.authors       = [
    'Javier Cuevas',
    'Raúl Marcos'
  ]
  spec.email         = ['javi@diacode.com', 'raulmarcosl@gmail.com']
  spec.summary       = 'Get your bank account details.'
  spec.description   = 'Command line tools to get bank account details from some banks.'
  spec.homepage      = 'https://github.com/bankscrap/bankscrap'
  spec.license       = 'MIT'

  spec.files         = Dir['README.md', 'lib/**/{*,.[a-z]*}', 'generators/**/{*,.[a-z]*}']
  spec.executables << 'bankscrap'
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.1'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'

  spec.add_dependency 'thor'
  spec.add_dependency 'mechanize'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'money'
  spec.add_dependency 'unicode-display_width'
end
