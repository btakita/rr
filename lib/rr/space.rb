module RR
  # RR::Space is a Dependency Injection http://en.wikipedia.org/wiki/Dependency_injection
  # and global state object for the RR framework. The RR::Space.instance
  # is a singleton that holds the state.
  class Space
    class << self
      def instance
        @instance ||= new
      end
      attr_writer :instance
      
      protected
      def method_missing(method_name, *args, &block)
        instance.__send__(method_name, *args, &block)
      end
    end

    attr_reader :double_insertions, :ordered_scenarios
    attr_accessor :trim_backtrace
    def initialize
      @double_insertions = HashWithObjectIdKey.new
      @ordered_scenarios = []
      @trim_backtrace = false
    end

    def scenario_method_proxy(creator, object, method_name=nil, &definition)
      if method_name && definition
        raise ArgumentError, "Cannot pass in a method name and a block"
      end
      proxy = DoubleMethodProxy.new(self, creator, object, &definition)
      return proxy unless method_name
      proxy.__send__(method_name)
    end

    # Creates a DoubleCreator.
    def scenario_creator
      DoubleCreator.new(self)
    end

    # Creates and registers a Double to be verified.
    def scenario(double_insertion, definition = scenario_definition)
      scenario = Double.new(self, double_insertion, definition)
      scenario.definition.scenario = scenario
      double_insertion.register_scenario scenario
      scenario
    end

    def scenario_definition
      DoubleDefinition.new(self)
    end

    # Reuses or creates, if none exists, a DoubleInsertion for the passed
    # in object and method_name.
    # When a DoubleInsertion is created, it binds the dispatcher to the
    # object.
    def double_insertion(object, method_name)
      double_insertion = @double_insertions[object][method_name.to_sym]
      return double_insertion if double_insertion

      double_insertion = DoubleInsertion.new(self, object, method_name.to_sym)
      @double_insertions[object][method_name.to_sym] = double_insertion
      double_insertion.bind
      double_insertion
    end

    # Registers the ordered Double to be verified.
    def register_ordered_scenario(scenario)
      @ordered_scenarios << scenario
    end

    # Verifies that the passed in ordered Double is being called
    # in the correct position.
    def verify_ordered_scenario(scenario)
      unless scenario.terminal?
        raise Errors::DoubleOrderError,
              "Ordered Doubles cannot have a NonTerminal TimesCalledExpectation"
      end
      unless @ordered_scenarios.first == scenario
        message = Double.formatted_name(scenario.method_name, scenario.expected_arguments)
        message << " called out of order in list\n"
        message << Double.list_message_part(@ordered_scenarios)
        raise Errors::DoubleOrderError, message
      end
      @ordered_scenarios.shift unless scenario.attempt?
      scenario
    end

    # Verifies all the DoubleInsertion objects have met their
    # TimesCalledExpectations.
    def verify_double_insertions
      @double_insertions.each do |object, method_double_map|
        method_double_map.keys.each do |method_name|
          verify_double(object, method_name)
        end
      end
    end

    # Resets the registered Doubles and ordered Doubles
    def reset
      reset_ordered_scenarios
      reset_double_insertions
    end

    # Verifies the DoubleInsertion for the passed in object and method_name.
    def verify_double(object, method_name)
      @double_insertions[object][method_name].verify
    ensure
      reset_double object, method_name
    end

    # Resets the DoubleInsertion for the passed in object and method_name.
    def reset_double(object, method_name)
      double_insertion = @double_insertions[object].delete(method_name)
      @double_insertions.delete(object) if @double_insertions[object].empty?
      double_insertion.reset
    end

    protected
    # Removes the ordered Doubles from the list
    def reset_ordered_scenarios
      @ordered_scenarios.clear
    end

    # Resets the registered Doubles for the next test run.
    def reset_double_insertions
      @double_insertions.each do |object, method_double_map|
        method_double_map.keys.each do |method_name|
          reset_double(object, method_name)
        end
      end
    end    
  end
end