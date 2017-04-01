require 'active_record_bitmask_attributes/version'
require 'active_support/concern'

module ActiveRecordBitmaskAttributes
  autoload :AttributeMethods, 'active_record_bitmask_attributes/attribute_methods'
  autoload :Core, 'active_record_bitmask_attributes/core'
  autoload :Definition, 'active_record_bitmask_attributes/definition'
  autoload :Mappings, 'active_record_bitmask_attributes/mappings'
  autoload :Model, 'active_record_bitmask_attributes/model'
end
