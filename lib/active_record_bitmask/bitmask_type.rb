# frozen_string_literal: true

require 'active_model'

module ActiveRecordBitmask
  class BitmaskType < ActiveModel::Type::Value
    # @param name [String]
    # @param map [ActiveRecordBitmask::Map]
    # @param sub_type [ActiveModel::Type::Value]
    def initialize(name, map, sub_type)
      @map = map
      @sub_type = sub_type
    end

    # @return [Symbol]
    def type
      @sub_type.type
    end

    # @return [Array<Symbol>]
    def cast(value)
      return [] if value.blank?

      bitmask = @map.bitmask_or_attributes_to_bitmask(value)
      @map.bitmask_to_attributes(bitmask)
    end

    # @return [Integer]
    def serialize(value)
      @map.bitmask_or_attributes_to_bitmask(value) || 0
    end

    # @param raw_value [Integer, nil]
    #
    # @return [Array<Symbol>]
    def deserialize(raw_value)
      value = @sub_type.deserialize(raw_value)
      return [] if value.nil?

      @map.bitmask_to_attributes(value)
    end
  end
end
