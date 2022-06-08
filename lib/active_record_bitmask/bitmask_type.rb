# frozen_string_literal: true

module ActiveRecordBitmask
  class BitmaskType < ActiveModel::Type::Value
    # @param name [String]
    # @param map [ActiveRecordBitmask::Map]
    # @param sub_type [ActiveModel::Type::Value]
    def initialize(_name, map, sub_type)
      super()
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

    # @param raw_old_value [Integer]
    # @param new_value [Array<Symbol>]
    #
    # @return [boolean]
    def changed_in_place?(raw_old_value, new_value)
      raw_old_value.nil? != new_value.nil? ||
        cast(raw_old_value) != cast(new_value)
    end
  end
end
