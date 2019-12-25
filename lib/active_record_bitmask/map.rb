# frozen_string_literal: true

module ActiveRecordBitmask
  class Map
    attr_reader :mapping

    # @param keys [Array<#to_sym>]
    def initialize(keys)
      @mapping = attributes_to_mapping(keys).freeze
    end

    # @param value [Integer, Symbol, Array<#to_sym>]
    #
    # @return [Integer]
    def bitmask_or_attributes_to_bitmask(value)
      value = bitmask_to_attributes(value) if value.is_a?(Integer)
      attributes_to_bitmask(value)
    end

    # @param bitmask [Integer]
    #
    # @return [Array<Integer>]
    def bitmask_combination(bitmask)
      return [] if bitmask.to_i.zero?

      max_value = values.max
      combination_pattern_size = (max_value << 1) - 1
      0.upto(combination_pattern_size).select { |i| i & bitmask == bitmask }
    end

    # @return [Range<Integer>]
    def all_combination
      max_bit = values.size
      max_value = (2 << (max_bit - 1)) - 1

      1..max_value
    end

    # @param bitmask [Integer]
    #
    # @return [Array<Symbol>]
    def bitmask_to_attributes(bitmask)
      return [] if bitmask.to_i.zero?

      mapping.each_with_object([]) do |(key, value), values|
        values << key.to_sym if (value & bitmask).nonzero?
      end
    end

    # @param attributes [Array<#to_sym>]
    #
    # @return [Integer]
    def attributes_to_bitmask(attributes)
      attributes = [attributes].compact unless attributes.respond_to?(:inject)
      return if attributes.empty?

      attributes.inject(0) do |bitmask, key|
        key = key.to_sym if key.respond_to?(:to_sym)
        bit = mapping.fetch(key) { raise(ArgumentError, "#{key.inspect} is not a valid value") }
        bitmask | bit
      end
    end

    # @return [Array<Symbol>]
    def keys
      mapping.keys
    end

    # @return [Array<Integer>]
    def values
      mapping.values
    end

    private

    def attributes_to_mapping(keys)
      keys.each_with_index.each_with_object({}) do |(value, index), hash|
        hash[value.to_sym] = 0b1 << index
      end
    end
  end
end
