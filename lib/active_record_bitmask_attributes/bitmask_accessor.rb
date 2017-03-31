module ActiveRecordBitmaskAttributes
  module BitmaskAccessor
    extend ActiveSupport::Concern

    class_methods do
      def bitmask(attribute, **options)
        attribute = attribute.to_sym
        raise ArgumentError, "#{attribute} is already defined" if _bitmask_mappings.key?(attribute)
        _bitmask_mappings[attribute] = ActiveRecordBitmaskAttributes::Mappings.new(attribute, **options)
        ActiveRecordBitmaskAttributes::Definition.define_methods(self, attribute)
      end

      def _bitmask_mappings
        base_class._base_bitmask_mappings
      end

      protected

      def _base_bitmask_mappings
        @_base_bitmask_mappings ||= {}
      end
    end
  end
end
