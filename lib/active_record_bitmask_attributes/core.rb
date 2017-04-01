module ActiveRecordBitmaskAttributes
  module Core
    extend ActiveSupport::Concern

    included do
      include AttributeMethods::Query
    end

    module ClassMethods
      def define_attribute_methods
        super
        return false if @bitmask_methods_generated

        generated_bitmask_methods.synchronize do
          return false if @bitmask_methods_generated

          self.bitmasks.keys.each do |key|
            define_bitmask_reader_and_writer(key)
          end

          @bitmask_methods_generated = true
        end

        true
      end

      private

      def generated_bitmask_methods #:nodoc:
        @generated_bitmask_methods ||= Module.new {
          extend Mutex_m
        }.tap { |mod| include mod }
      end

      def define_bitmask_reader_and_writer(attribute)
        generated_bitmask_methods.module_eval(<<-METHOD, __FILE__, __LINE__ + 1)
          def #{attribute}
            mappings = self.class.bitmask_for(:#{attribute})
            bitmask = mappings.bitmask_or_attributes_to_bitmask(super)
            mappings.bitmask_to_attributes(bitmask)
          end

          def #{attribute}=(value)
            mappings = self.class.bitmask_for(:#{attribute})
            bitmask = mappings.bitmask_or_attributes_to_bitmask(value)
            super(bitmask)
          end
        METHOD
      end
    end
  end
end
