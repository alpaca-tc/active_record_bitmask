require 'active_record_bitmask_attributes/version'

module ActiveRecordBitmaskAttributes
  autoload :AttributeMethods, 'active_record_bitmask_attributes/attribute_methods'
  autoload :Bitmask, 'active_record_bitmask_attributes/bitmask'
  autoload :BitmaskAccessor, 'active_record_bitmask_attributes/bitmask_accessor'
  autoload :Definition, 'active_record_bitmask_attributes/definition'
  autoload :Mappings, 'active_record_bitmask_attributes/mappings'
end
