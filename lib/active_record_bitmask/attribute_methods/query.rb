# frozen_string_literal: true

require 'active_record'
require 'active_support/concern'

module ActiveRecordBitmask
  module AttributeMethods
    module Query
      extend ActiveSupport::Concern

      included do
        attribute_method_suffix('_bitmask?')
      end

      private

      def bitmask_attribute?(attribute_name)
        self.class.bitmasks.key?(attribute_name.to_sym)
      end

      def attribute_bitmask?(attribute_name, *values)
        if bitmask_attribute?(attribute_name) && values.present?
          # assert bitmask values
          map = self.class.bitmask_for(attribute_name)
          expected_value = map.attributes_to_bitmask(values)
          current_value = map.attributes_to_bitmask(attribute(attribute_name))

          current_value.allbits?(expected_value)
        else
          attribute?(attribute_name)
        end
      end
    end
  end
end
