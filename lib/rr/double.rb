module RR
  # RR::Double is the binding of an object and a method.
  # A double has 0 to many Scenario objects. Each Scenario
  # has Argument Expectations and Times called Expectations.
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

    # RR::Double#register_scenario adds the passed in Scenario
    # into this Double's list of Scenario objects.
    def register_scenario(scenario)
      @scenarios << scenario
    end

    # RR::Double#bind injects a method that acts as a dispatcher
    # that dispatches to the matching Scenario when the method
    # is called.    
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

    # RR::Double#verify verifies each Scenario
    # TimesCalledExpectation are met.
    def verify
      @scenarios.each do |scenario|
        scenario.verify
      end
    end

    # RR::Double#reset removes the injected dispatcher method.
    # It binds the original method implementation on the object
    # if one exists. 
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
      if scenario = find_scenario_to_attempt(args)
        return scenario.call(*args, &block)
      end
      scenario_not_found_error(*args)
    end

    protected
    def find_scenario_to_attempt(args)
      matches = ScenarioMatches.new(@scenarios).match(args)

      unless matches.exact_terminal_scenarios_to_attempt.empty?
        return matches.exact_terminal_scenarios_to_attempt.first
      end

      unless matches.exact_non_terminal_scenarios_to_attempt.empty?
        return matches.exact_non_terminal_scenarios_to_attempt.last
      end

      unless matches.wildcard_terminal_scenarios_to_attempt.empty?
        return matches.wildcard_terminal_scenarios_to_attempt.first
      end

      unless matches.wildcard_non_terminal_scenarios_to_attempt.empty?
        return matches.wildcard_non_terminal_scenarios_to_attempt.last
      end

      unless matches.matching_scenarios.empty?
        # This will raise a TimesCalledError
        return matches.matching_scenarios.first
      end

      return nil
    end

    def scenario_not_found_error(*args)
      message = "No scenario for #{Scenario.formatted_name(@method_name, args)} in\n"
      message << Scenario.list_message_part(@scenarios)
      raise Errors::ScenarioNotFoundError, message
    end

    def placeholder_name
      "__rr__#{@method_name}"
    end
    
    def meta
      (class << @object; self; end)
    end
  end
end
