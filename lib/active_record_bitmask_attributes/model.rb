module ActiveRecordBitmaskAttributes
  module Model
    extend ActiveSupport::Concern

    class_methods do
      def bitmask(attribute, **options)
        attribute = attribute.to_sym
        raise ArgumentError, "#{attribute} is already defined" if bitmasks.key?(attribute)
        _bitmask_mappings[attribute] = ActiveRecordBitmaskAttributes::Mappings.new(attribute, **options)
        ActiveRecordBitmaskAttributes::Definition.define_methods(self, attribute)
      end

      def bitmasks
        _bitmask_mappings
      end

      def bitmask_for(attribute)
        attribute = attribute.to_sym
        bitmasks[attribute]
      end

      def bitmask_keys_for(attribute)
        bitmask_for(attribute).mappings.keys
      end

      protected

      def _bitmask_mappings
        base_class._base_bitmask_mappings
      end

      def _base_bitmask_mappings
        @_base_bitmask_mappings ||= {}
      end
    end
  end
end
