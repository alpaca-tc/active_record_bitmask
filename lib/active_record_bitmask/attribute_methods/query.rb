# frozen_string_literal: true

module ActiveRecordBitmask
  module AttributeMethods
    module Query
      private

      def bitmask_attribute?(attribute_name)
        self.class.bitmasks.key?(attribute_name.to_sym)
      end

      def attribute?(attribute_name, *values)
        if bitmask_attribute?(attribute_name) && values.present?
          # assert bitmask values
          map = self.class.bitmask_for(attribute_name)
          map.attributes_to_bitmask(values)

          current_value = attribute(attribute_name)
          values.all? { |value| current_value.include?(value) }
        else
          super
        end
      end
    end
  end
end
