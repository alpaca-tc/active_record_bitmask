# frozen_string_literal: true

require 'active_record_bitmask/version'
require 'active_support/concern'

module ActiveRecordBitmask
  autoload :AttributeMethods, 'active_record_bitmask/attribute_methods'
  autoload :Bitmask, 'active_record_bitmask/bitmask'
  autoload :Core, 'active_record_bitmask/core'
  autoload :Definition, 'active_record_bitmask/definition'
  autoload :Mappings, 'active_record_bitmask/mappings'
  autoload :Model, 'active_record_bitmask/model'
end
