# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record_bitmask/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_record_bitmask'
  spec.version       = ActiveRecordBitmask::VERSION
  spec.authors       = ['alpaca-tc']
  spec.email         = ['alpaca-tc@alpaca.tc']
  spec.licenses      = ['MIT']

  spec.summary       = 'Simple bitmask attribute support for ActiveRecord'
  spec.homepage      = 'https://github.com/alpaca-tc/active_record_bitmask'

  spec.required_ruby_version = '>= 2.5.0'

  spec.metadata = {
    'homepage_uri' => 'https://github.com/alpaca-tc/active_record_bitmask',
    'changelog_uri' => 'https://github.com/alpaca-tc/active_record_bitmask/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/alpaca-tc/active_record_bitmask/',
    'bug_tracker_uri' => 'https://github.com/alpaca-tc/active_record_bitmask/issues'
  }

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 5.0'
end
