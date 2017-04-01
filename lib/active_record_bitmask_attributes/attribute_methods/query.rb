module ActiveRecordBitmaskAttributes
  module AttributeMethods
    module Query
      private

      def bitmask_attribute?(attribute_name)
        self.class.bitmask_for(attribute_name.to_sym).present?
      end

      def attribute?(attribute_name, *values)
        if bitmask_attribute?(attribute_name) && values.present?
          # assert bitmask values
          mappings = self.class.bitmask_for(attribute_name.to_sym)
          mappings.attributes_to_bitmask(values)

          values.all? do |value|
            (__send__(attribute_name) || []).include?(value)
          end
        else
          super
        end
      end
    end
  end
end
