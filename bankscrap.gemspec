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
  spec.homepage      = 'https://github.com/bank-scrap/bank_scrap'
  spec.license       = 'MIT'

  spec.files         = Dir['README.md', 'lib/**/{*,.[a-z]*}', 'generators/**/{*,.[a-z]*}']
  spec.executables << 'bankscrap'
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.1'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'byebug',  '~> 3.5', '>= 3.5.1'
  spec.add_development_dependency 'rubocop', '~> 0.39.0'

  spec.add_dependency 'thor',          '~> 0.19'
  spec.add_dependency 'mechanize',     '~> 2.7.4'
  spec.add_dependency 'activesupport', '~> 4.1'
  spec.add_dependency 'money',         '~> 6.5.0'
end
