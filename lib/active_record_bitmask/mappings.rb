# frozen_string_literal: true

module ActiveRecordBitmask
  class Mappings
    attr_reader :attribute, :mappings

    # @param attribute [Symbol]
    # @param as [Array<#to_sym>]
    def initialize(attribute, as: [])
      @attribute = attribute
      @mappings = attributes_to_mappings(as).freeze
    end

    def bitmask_or_attributes_to_bitmask(value)
      value = bitmask_to_attributes(value) if value.is_a?(Integer)
      attributes_to_bitmask(value)
    end

    # @param bitmask [Integer]
    #
    # @return [Array<Integer>]
    def bitmask_combination(bitmask)
      return [] if bitmask.to_i.zero?

      max_value = mappings.values.max
      combination_pattern_size = (max_value << 1) - 1
      0.upto(combination_pattern_size).select { |i| i & bitmask == bitmask }
    end

    # @param bitmask [Integer]
    #
    # @return [Array<Symbol>]
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

    # @return [Array<Symbol>]
    def keys
      mappings.keys
    end

    private

    def attributes_to_mappings(keys)
      keys.each_with_index.each_with_object({}) do |(value, index), hash|
        hash[value.to_sym] = 0b1 << index
      end
    end
  end
end
