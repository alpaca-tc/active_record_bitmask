module ActiveRecordBitmaskAttributes
  class Bitmask < DelegateClass(Array)
    attr_reader :bitmask

    def initialize(value, mappings)
      @bitmask = mappings.bitmask_or_attributes_to_bitmask(value)

      attributes = mappings.bitmask_to_attributes(@bitmask)
      super(attributes)
    end
  end
end
