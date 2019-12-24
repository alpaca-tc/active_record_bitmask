# frozen_string_literal: true

require 'active_support/lazy_load_hooks'

module ActiveRecordBitmask
  require 'active_record_bitmask/version'
  require 'active_record_bitmask/attribute_methods'
  require 'active_record_bitmask/bitmask_type'
  require 'active_record_bitmask/map'
end

ActiveSupport.on_load :active_record do
  require 'active_record_bitmask/model'
  include(ActiveRecordBitmask::Model)
end
