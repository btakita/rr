module RR
  class Double
    MethodArguments = Struct.new(:arguments, :block)
    attr_reader :space, :object, :method_name, :original_method, :scenarios

    def initialize(space, object, method_name)
      @space = space
      @object = object
      @method_name = method_name.to_sym
      @original_method = object.method(method_name) if @object.methods.include?(method_name.to_s)
      @scenarios = []
    end
    
    def register_scenario(scenario)
      @scenarios << scenario
    end

    def bind
      define_implementation_placeholder
      returns_method = <<-METHOD
        def #{@method_name}(*args, &block)
          arguments = MethodArguments.new(args, block)
          #{placeholder_name}(arguments)
        end
      METHOD
      meta.class_eval(returns_method, __FILE__, __LINE__ - 5)
    end

    def verify
      @scenarios.each do |scenario|
        scenario.verify
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
      meta.send(:define_method, placeholder_name) do |arguments|
        me.send(:call_method, arguments.arguments, arguments.block)
      end
    end

    def call_method(args, block)
      matching_scenarios = []
      @scenarios.each do |scenario|
        if scenario.exact_match?(*args)
          matching_scenarios << scenario
          return scenario.call(*args, &block) unless scenario.times_called_verified?
        end
      end
      @scenarios.each do |scenario|
        if scenario.wildcard_match?(*args)
          matching_scenarios << scenario
          return scenario.call(*args, &block) unless scenario.times_called_verified?
        end
      end
      matching_scenarios.first.call(*args) unless matching_scenarios.empty?
      raise ScenarioNotFoundError, "No scenario for arguments #{args.inspect}"
    end
    
    def placeholder_name
      "__rr__#{@method_name}__rr__"
    end
    
    def meta
      (class << @object; self; end)
    end
  end
end
