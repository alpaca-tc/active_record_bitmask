# frozen_string_literal: true

module ActiveRecordBitmask
  class Mappings
    attr_reader :attribute, :mappings

    def initialize(attribute, options = {})
      unless options[:as].is_a?(Array)
        raise ArgumentError, 'must provide an Array :as option'
      end

      @attribute = attribute
      @mappings = attributes_to_mappings(options[:as]).freeze
    end

    def bitmask_or_attributes_to_bitmask(value)
      value = bitmask_to_attributes(value) if value.is_a?(Integer)
      attributes_to_bitmask(value)
    end

    def bitmask_combination(bitmask)
      return [] if bitmask.to_i.zero?

      max_value = mappings.values.max
      combination_pattern_size = (max_value << 1) - 1
      0.upto(combination_pattern_size).select { |i| i & bitmask == bitmask }
    end

    def bitmask_to_attributes(bitmask)
      return [] if bitmask.to_i.zero?

      mappings.each_with_object([]) do |(key, value), values|
        values << key.to_sym if (value & bitmask).nonzero?
      end
    end

    def attributes_to_bitmask(attributes)
      attributes = [attributes].compact unless attributes.respond_to?(:inject)
      return if attributes.empty?

      attributes.inject(0) do |bitmask, key|
        key = key.to_sym if key.respond_to?(:to_sym)
        bit = mappings.fetch(key) { raise(ArgumentError, "#{key.inspect} is not a valid #{attribute}") }
        bitmask | bit
      end
    end

    private

    def attributes_to_mappings(attributes)
      attributes.each_with_index.each_with_object({}) { |(value, index), hash|
        hash[value.to_sym] = 0b1 << index
      }
    end
  end
end
