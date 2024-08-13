# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'active_record_bitmask'
require 'active_record'
require 'pry'

RSpec.configure do |config|
  Kernel.srand(config.seed)

  config.expose_dsl_globally = false
  config.raise_errors_for_deprecations!
  config.order = :random
  config.profile_examples = 10

  unless ENV.fetch('CIRCLECI', nil) || ENV.fetch('TRAVIS', nil)
    config.filter_run :focus
    config.run_all_when_everything_filtered = true
  end

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end
end

Dir['./spec/support/**/*.rb'].each { |f| require f }
