module ActiveRecordBitmaskAttributes
  class Mappings
    attr_reader :attribute, :mappings

    def initialize(attribute, options = {})
      unless options[:as].kind_of?(Array)
        raise ArgumentError, 'must provide an Array :as option'
      end

      @attribute = attribute

      as = options[:as]
      @mappings = as.each_with_index.each_with_object({}) do |(value, index), hash|
        hash[value.to_sym] = 0b1 << index
      end
    end

    def bitmask_or_attributes_to_bitmask(value)
      value = bitmask_to_attributes(value) if value.is_a?(Integer)
      attributes_to_bitmask(value)
    end

    def bitmask_combination(bitmask)
      return [] if bitmask.to_i.zero?

      max_value = mappings.values.max
      combination_pattern_size = (max_value << 1) - 1
      0.upto(combination_pattern_size).select  { |i| i & bitmask == bitmask }
    end

    def bitmask_to_attributes(bitmask)
      return [] if bitmask.to_i.zero?

      mappings.each_with_object([]) do |(key, value), values|
        values << key.to_sym if (value & bitmask).nonzero?
      end
    end

    def attributes_to_bitmask(attributes)
      attributes = [attributes].compact unless attributes.is_a?(Array)
      return if attributes.empty?

      attributes.inject(0) do |bitmask, key|
        bit = mappings.fetch(key) { raise(ArgumentError, ":#{key} is not a valid #{attribute}") }
        bitmask | bit
      end
    end
  end
end
