module ActiveRecordBitmaskAttributes
  class Definition
    def self.define_methods(klass, attribute)
      klass.include(AttributeMethods) unless klass < AttributeMethods

      build_bitmask = ->(value) {
        mappings = klass.bitmask_for(attribute)
        ActiveRecordBitmaskAttributes::Bitmask.new(value, mappings).freeze
      }

      klass.composed_of attribute,
        mapping: [attribute, :bitmask],
        class_name: 'ActiveRecordBitmaskAttributes::Bitmask',
        constructor: build_bitmask,
        converter: build_bitmask

      klass.scope :"with_#{attribute}", ->(*values) {
        mappings = klass.bitmask_for(attribute)
        bitmask = ActiveRecordBitmaskAttributes::Bitmask.new(values, mappings)
        combination = mappings.bitmask_combination(bitmask.bitmask)

        where(attribute => combination)
      }
    end
  end
end
