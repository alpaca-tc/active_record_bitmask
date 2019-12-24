# frozen_string_literal: true

require 'active_support/concern'

module ActiveRecordBitmask
  module Model
    extend ActiveSupport::Concern

    included do
      include ActiveRecordBitmask::AttributeMethods::Query
    end

    class_methods do
      # @param definitions [Hash]
      #
      # @return [void]
      def bitmask(definitions)
        definitions.each do |attribute, values|
          define_bitmask(attribute, values)
        end
      end

      def bitmasks
        _bitmask_maps
      end

      # @param attribute [#to_s]
      #
      # @raise [KeyError]
      #
      # @return [ActiveRecordBitmask::Map]
      def bitmask_for(attribute)
        bitmasks.fetch(attribute.to_sym)
      end

      protected

      def _bitmask_maps
        base_class._base_bitmask_maps
      end

      def _base_bitmask_maps
        @_base_bitmask_maps ||= {}
      end

      private

      def define_bitmask(attribute, values)
        attribute = attribute.to_sym

        raise ArgumentError, "#{attribute} is already defined" if bitmasks.key?(attribute)
        raise ArgumentError, 'must provide an Array option' if values.empty?

        map = ActiveRecordBitmask::Map.new(values)
        _bitmask_maps[attribute] = map

        decorate_attribute_type(attribute, :bitmask) do |subtype|
          ActiveRecordBitmask::BitmaskType.new(attribute, map, subtype)
        end

        scope :"with_#{attribute}", ->(*values) {
          bitmask = map.bitmask_or_attributes_to_bitmask(values)
          combination = map.bitmask_combination(bitmask)

          where(attribute => combination)
        }
      end
    end
  end
end
