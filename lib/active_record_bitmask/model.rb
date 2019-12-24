# frozen_string_literal: true

require 'active_support/concern'

module ActiveRecordBitmask
  module Model
    extend ActiveSupport::Concern

    class_methods do
      # @param attribute [#to_sym]
      # @param as [Array<#to_sym>]
      #
      # @return [void]
      def bitmask(attribute, as: [])
        attribute = attribute.to_sym
        raise ArgumentError, "#{attribute} is already defined" if bitmasks.key?(attribute)
        raise ArgumentError, 'must provide an Array :as option' if as.empty?

        _bitmask_maps[attribute] = ActiveRecordBitmask::Map.new(as)
        ActiveRecordBitmask::Definition.define_methods(self, attribute)
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
    end
  end
end
