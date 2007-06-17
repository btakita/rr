module RR
  class Double
    attr_reader :space, :object, :method_name, :original_method, :times_called, :expectations, :scenarios
    attr_accessor :double_method
    
    def initialize(space, object, method_name)
      @space = space
      @object = object
      @method_name = method_name.to_sym
      @original_method = object.method(method_name) if @object.methods.include?(method_name.to_s)
      @expectations = {}
      @times_called = 0
      @scenarios = []
    end

    def add_expectation(expectation)
      @expectations[expectation.class] = expectation
    end

    def bind
      define_implementation_placeholder
      returns_method = <<-METHOD
        def #{@method_name}(*args, &block)
          if block
            args << block
            #{placeholder_name}(*args)
          else
            #{placeholder_name}(*args)
          end
        end
      METHOD
      meta.class_eval(returns_method, __FILE__, __LINE__ - 9)
    end

    def verify_input(*args)
      @expectations.each do |expectation_type, expectation|
        expectation.verify_input *args
      end
    end

    def verify
      @expectations.each do |expectation_type, expectation|
        expectation.verify self
      end
    end

    def reset
      meta.send(:remove_method, placeholder_name)
      if @original_method
        meta.send(:define_method, @method_name, &@original_method)
      else
        meta.send(:remove_method, @method_name)
      end
    end

    protected
    def define_implementation_placeholder
      me = self
      meta.send(:define_method, placeholder_name) do |*args|
        me.send(:call_method, *args)
      end
    end

    def call_method(*args)
      self.verify_input(*args)
      @times_called += 1
      @double_method.call(*args)
    end
    
    def placeholder_name
      "__rr__#{@method_name}__rr__"
    end
    
    def meta
      (class << @object; self; end)
    end
  end
end
