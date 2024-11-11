# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/core_ext/class/attribute'

module ActiveRecordBitmask
  module Model
    extend ActiveSupport::Concern

    included do
      include ActiveRecordBitmask::AttributeMethods::Query
      class_attribute(:bitmasks, instance_accessor: false)

      # `class_attribute` on Rails 5.0 doesn't support default option.
      self.bitmasks = {}
    end

    class_methods do
      # @param base [ActiveRecord::Base]
      def inherited(base)
        base.bitmasks = bitmasks.deep_dup
        super
      end

      # @param definitions [Hash]
      #
      # @return [void]
      def bitmask(definitions)
        definitions.each do |attribute, values|
          raise ArgumentError, 'must provide an Array option' if values.empty?

          attribute = attribute.to_sym
          map = ActiveRecordBitmask::Map.new(values)

          bitmasks[attribute] = map

          define_bitmask_attribute(attribute, map)
          define_bitmask_scopes(attribute)
        end
      end

      # @param attribute [#to_sym]
      #
      # @raise [KeyError]
      #
      # @return [ActiveRecordBitmask::Map]
      def bitmask_for(attribute)
        bitmasks.fetch(attribute.to_sym)
      end

      private

      def define_bitmask_attribute(attribute, map)
        if ActiveRecord.gem_version >= Gem::Version.new('7.2.0')
          # Greater than or equal to 7.2.0
          decorate_attributes([attribute]) do |name, subtype|
            ActiveRecordBitmask::BitmaskType.new(name, map, subtype)
          end
        else
          # Greater than or equal to 7.0.0
          attribute(attribute) do |subtype|
            ActiveRecordBitmask::BitmaskType.new(attribute, map, subtype)
          end
        end
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def define_bitmask_scopes(attribute)
        blank = [0, nil].freeze

        scope :"with_#{attribute}", ->(*values) {
          map = bitmask_for(attribute)
          bitmask = map.bitmask_or_attributes_to_bitmask(values)
          combination = map.bitmask_combination(bitmask)

          if bitmask.zero?
            where(attribute => map.all_combination)
          else
            where(attribute => combination)
          end
        }

        scope :"with_any_#{attribute}", ->(*values) {
          map = bitmask_for(attribute)
          bitmasks = values.map { |value| map.bitmask_or_attributes_to_bitmask(value) }
          combination = bitmasks.flat_map { |bitmask| map.bitmask_combination(bitmask) }

          if combination.empty?
            where(attribute => map.all_combination)
          else
            where(attribute => combination)
          end
        }

        scope :"without_#{attribute}", ->(*values) {
          map = bitmask_for(attribute)
          bitmasks = values.map { |value| map.bitmask_or_attributes_to_bitmask(value) }
          combination = bitmasks.flat_map { |bitmask| map.bitmask_combination(bitmask) }

          if values.empty?
            public_send(:"no_#{attribute}")
          else
            excepted = (map.all_combination.to_a + blank) - combination
            where(attribute => excepted)
          end
        }

        scope :"with_exact_#{attribute}", ->(*values) {
          map = bitmask_for(attribute)
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
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end
end
