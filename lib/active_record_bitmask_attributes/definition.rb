module ActiveRecordBitmaskAttributes
  class Definition
    class BitmaskType < ::ActiveRecord::Type::Value
      delegate :type, to: :subtype

      def initialize(name, mappings, subtype)
        @name = name
        @mappings = mappings
        @subtype = subtype
      end

      def cast(value)
        @subtype.cast(build_bitmask(value).bitmask.to_i)
      end

      protected

      attr_reader :name, :mapping, :subtype

      private

      def build_bitmask(value)
        ActiveRecordBitmaskAttributes::Bitmask.new(value, @mappings)
      end
    end

    def self.define_methods(klass, attribute)
      klass.include(AttributeMethods::Query) unless klass < AttributeMethods::Query

      build_bitmask = ->(value) {
        mappings = klass.bitmask_for(attribute)
        ActiveRecordBitmaskAttributes::Bitmask.new(value, mappings).freeze
      }

      klass.composed_of attribute,
        mapping: [attribute, :bitmask],
        class_name: 'ActiveRecordBitmaskAttributes::Bitmask',
        allow_nil: true,
        constructor: build_bitmask,
        converter: build_bitmask

      klass.scope :"with_#{attribute}", ->(*values) {
        mappings = klass.bitmask_for(attribute)
        bitmask = ActiveRecordBitmaskAttributes::Bitmask.new(values, mappings)
        combination = mappings.bitmask_combination(bitmask.bitmask)

        where(attribute => combination)
      }

      klass.decorate_attribute_type(attribute, :enum) do |subtype|
        BitmaskType.new(attribute, klass.bitmask_for(attribute), subtype)
      end
    end
  end
end
