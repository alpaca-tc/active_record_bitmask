# frozen_string_literal: true

module ActiveRecordBitmask
  class Definition
    def self.define_methods(klass, attribute)
      klass.include(ActiveRecordBitmask::Core) unless klass < ActiveRecordBitmask::Core

      unless klass.respond_to?(:"with_#{attribute}")
        klass.scope :"with_#{attribute}", ->(*values) {
          mappings = klass.bitmask_for(attribute)
          bitmask = mappings.bitmask_or_attributes_to_bitmask(values)
          combination = mappings.bitmask_combination(bitmask)

          where(attribute => combination)
        }
      end
    end
  end
end
