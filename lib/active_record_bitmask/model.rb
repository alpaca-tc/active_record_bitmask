# frozen_string_literal: true

require 'active_support/concern'

module ActiveRecordBitmask
  module Model
    extend ActiveSupport::Concern

    class_methods do
      def bitmask(attribute, **options)
        attribute = attribute.to_sym
        raise ArgumentError, "#{attribute} is already defined" if bitmasks.key?(attribute)

        _bitmask_mappings[attribute] = ActiveRecordBitmask::Mappings.new(attribute, **options)
        ActiveRecordBitmask::Definition.define_methods(self, attribute)
      end

      def bitmasks
        _bitmask_mappings
      end

      # @param attribute [#to_s]
      #
      # @raise [KeyError]
      #
      # @return [ActiveRecordBitmask::Mappings]
      def bitmask_for(attribute)
        bitmasks.fetch(attribute.to_sym)
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
