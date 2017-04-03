module ActiveRecordBitmaskAttributes
  class Bitmask < DelegateClass(Array)
    def self.define_destructive_method(method_name)
      class_eval(<<-METHOD, __FILE__, __LINE__ + 1)
        def #{method_name}(*)
          super
          @instance.public_send("#\{@attribute}=", self)
        end
      METHOD
    end

    [
      :<<, :select!, :keep_if, :delete_if, :reject!, :uniq!,
      :clear, :replace, :concat, :delete, :slice!, :push,
      :pop, :shift, :unshift
    ].each do |method_name|
      define_destructive_method(method_name)
    end

    def initialize(instance, attribute, *args)
      @instance = instance
      @attribute = attribute
      super(*args)
    end
  end
end
