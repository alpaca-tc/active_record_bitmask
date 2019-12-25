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
          raise ArgumentError, "#{attribute} is already defined" if bitmasks.key?(attribute)
          raise ArgumentError, 'must provide an Array option' if values.empty?

          attribute = attribute.to_sym

          map = ActiveRecordBitmask::Map.new(values)

          bitmasks[attribute] = map

          define_bitmask(attribute, map)
          define_bitmask_scopes(attribute, map)
        end
      end

      # @return [Hash<Symbol, ActiveRecordBitmask::Map>]
      def bitmasks
        base_class._base_bitmask_maps
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

      def _base_bitmask_maps
        @_base_bitmask_maps ||= {}
      end

      private

      def define_bitmask(attribute, map)
        decorate_attribute_type(attribute, :bitmask) do |subtype|
          ActiveRecordBitmask::BitmaskType.new(attribute, map, subtype)
        end
      end

      def define_bitmask_scopes(attribute, map)
        blank = [0, nil].freeze

        scope :"with_#{attribute}", ->(*values) {
          bitmask = map.bitmask_or_attributes_to_bitmask(values)
          combination = map.bitmask_combination(bitmask)

          where(attribute => combination)
        }

        scope :"with_any_#{attribute}", ->(*values) {
          bitmasks = values.map { |value| map.bitmask_or_attributes_to_bitmask(value) }
          combination = bitmasks.flat_map { |bitmask| map.bitmask_combination(bitmask) }

          where(attribute => combination)
        }

        scope :"without_#{attribute}", ->(*values) {
          bitmasks = values.map { |value| map.bitmask_or_attributes_to_bitmask(value) }
          combination = bitmasks.flat_map { |bitmask| map.bitmask_combination(bitmask) }
          all_combination = map.values.flat_map { |bitmask| map.bitmask_combination(bitmask) }

          if combination.empty?
            where(attribute => all_combination)
          else
            excepted = (all_combination + blank) - combination
            where(attribute => excepted)
          end
        }

        scope :"with_exact_#{attribute}", ->(*values) {
          bitmasks = values.map { |value| map.bitmask_or_attributes_to_bitmask(value) }
          bitmask = bitmasks.inject(0, &:|)

          if bitmask.zero?
            public_send(:"no_#{attribute}")
          else
            where(attribute => bitmask)
          end
        }

        scope :"no_#{attribute}", -> {
          where(attribute => blank)
        }
      end
    end
  end
end
