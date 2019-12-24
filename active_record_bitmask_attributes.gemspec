lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record_bitmask_attributes/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_record_bitmask_attributes'
  spec.version       = ActiveRecordBitmaskAttributes::VERSION
  spec.authors       = ['alpaca-tc']
  spec.email         = ['alpaca-tc@alpaca.tc']

  spec.summary       = %q{Simple bitmask attribute support for ActiveRecord}
  spec.homepage      = 'https://github.com/pixiv/active_record_bitmask_attributes'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 5.0'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
