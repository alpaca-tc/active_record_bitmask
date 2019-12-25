# frozen_string_literal: true

Module.new do
  def with_bitmask(klass, *args)
    klass.bitmask(*args)
    yield
  ensure
    klass.bitmasks.clear
  end

  RSpec.configure do |config|
    config.include(self)
  end
end
