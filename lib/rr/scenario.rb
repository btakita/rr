module RR
  # RR::Scenario is the use case for a method call.
  # It has the ArgumentEqualityExpectation, TimesCalledExpectation,
  # and the implementation.
  class Scenario
    class << self
      def formatted_name(method_name, args)
        formatted_errors = args.collect {|arg| arg.inspect}.join(', ')
        "#{method_name}(#{formatted_errors})"
      end

      def list_message_part(scenarios)
        scenarios.collect do |scenario|
          "- #{formatted_name(scenario.method_name, scenario.expected_arguments)}"
        end.join("\n")
      end
    end
    ORIGINAL_METHOD = Object.new

    attr_reader :times_called, :argument_expectation, :times_called_expectation, :double

    def initialize(space, double)
      @space = space
      @double = double
      @implementation = nil
      @argument_expectation = nil
      @times_called_expectation = nil
      @times_called = 0
      @after_call = nil
      @yields = nil
    end

    # Scenario#with sets the expectation that the Scenario will receive
    # the passed in arguments.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.with(1, 2) {:return_value}
    def with(*args, &returns)
      @argument_expectation = Expectations::ArgumentEqualityExpectation.new(*args)
      returns(&returns) if returns
      self
    end

    # Scenario#with_any_args sets the expectation that the Scenario can receive
    # any arguments.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.with_any_args {:return_value}
    def with_any_args(&returns)
      @argument_expectation = Expectations::AnyArgumentExpectation.new
      returns(&returns) if returns
      self
    end

    # Scenario#with_no_args sets the expectation that the Scenario will receive
    # no arguments.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.with_no_args {:return_value}
    def with_no_args(&returns)
      @argument_expectation = Expectations::ArgumentEqualityExpectation.new()
      returns(&returns) if returns
      self
    end

    # Scenario#never sets the expectation that the Scenario will never be
    # called.
    #
    # This method does not accept a block because it will never be called.
    #
    #   mock(subject).method_name.never
    def never
      @times_called_expectation = Expectations::TimesCalledExpectation.new(0)
      self
    end

    # Scenario#once sets the expectation that the Scenario will be called
    # 1 time.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.once {:return_value}
    def once(&returns)
      @times_called_expectation = Expectations::TimesCalledExpectation.new(1)
      returns(&returns) if returns
      self
    end

    # Scenario#twice sets the expectation that the Scenario will be called
    # 2 times.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.twice {:return_value}
    def twice(&returns)
      @times_called_expectation = Expectations::TimesCalledExpectation.new(2)
      returns(&returns) if returns
      self
    end

    # Scenario#at_least sets the expectation that the Scenario
    # will be called at least n times.
    # It works by creating a TimesCalledExpectation.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.at_least(4) {:return_value}
    def at_least(number, &returns)
      matcher = RR::TimesCalledMatchers::AtLeastMatcher.new(number)
      @times_called_expectation = Expectations::TimesCalledExpectation.new(matcher)
      returns(&returns) if returns
      self
    end

    # Scenario#at_most allows sets the expectation that the Scenario
    # will be called at most n times.
    # It works by creating a TimesCalledExpectation.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.at_most(4) {:return_value}
    def at_most(number, &returns)
      matcher = RR::TimesCalledMatchers::AtMostMatcher.new(number)
      @times_called_expectation = Expectations::TimesCalledExpectation.new(matcher)
      returns(&returns) if returns
      self
    end

    # Scenario#any_number_of_times sets an that the Scenario will be called
    # any number of times. This effectively removes the times called expectation
    # from the Scenarion
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.any_number_of_times
    def any_number_of_times(&returns)
      @times_called_expectation = Expectations::TimesCalledExpectation.new(TimesCalledMatchers::AnyTimesMatcher.new)
      returns(&returns) if returns
      self
    end

    # Scenario#times creates an TimesCalledExpectation of the passed
    # in number.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.times(4) {:return_value}
    def times(number, &returns)
      @times_called_expectation = Expectations::TimesCalledExpectation.new(number)
      returns(&returns) if returns
      self
    end

    # Scenario#ordered sets the Scenario to have an ordered
    # expectation.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.ordered {return_value}
    def ordered(&returns)
      @ordered = true
      @space.ordered_scenarios << self unless @space.ordered_scenarios.include?(self)
      returns(&returns) if returns
      self
    end

    # Scenario#ordered? returns true when the Scenario is ordered.
    #
    #   mock(subject).method_name.ordered?
    def ordered?
      @ordered
    end

    # Scenario#yields sets the Scenario to invoke a passed in block when
    # the Scenario is called.
    # An Expection will be raised if no block is passed in when the
    # Scenario is called.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.yields(yield_arg1, yield_arg2) {return_value}
    #   subject.method_name {|yield_arg1, yield_arg2|}
    def yields(*args, &returns)
      @yields = args
      returns(&returns) if returns
      self
    end

    # Scenario#after_call creates a callback that occurs after call
    # is called. The passed in block receives the return value of
    # the Scenario being called.
    # An Expection will be raised if no block is passed in.
    #
    #   mock(subject).method_name {return_value}.after_call {|return_value|}
    #   subject.method_name # return_value
    #
    # This feature is built into probes.
    #   probe(User).find('1') {|user| mock(user).valid? {false}}
    def after_call(&block)
      raise ArgumentError, "after_call expects a block" unless block
      @after_call = block
      self
    end

    # Scenario#returns accepts an argument value or a block.
    # It will raise an ArgumentError if both are passed in.
    #
    # Passing in a block causes Scenario to return the return value of
    # the passed in block.
    #
    # Passing in an argument causes Scenario to return the argument.
    def returns(value=nil, &implementation)
      if value && implementation
        raise ArgumentError, "returns cannot accept both an argument and a block"
      end
      if value.nil?
        implemented_by implementation
      else
        implemented_by proc {value}
      end
    end

    # Scenario#implemented_by sets the implementation of the Scenario.
    # This method takes a Proc or a Method. Passing in a Method allows
    # the Scenario to accept blocks.
    #
    #   obj = Object.new
    #   def obj.foobar
    #     yield(1)
    #   end
    #   mock(obj).method_name.implemented_by(obj.method(:foobar))
    def implemented_by(implementation)
      @implementation = implementation
      self
    end

    # Scenario#implemented_by_original_method sets the implementation
    # of the Scenario to be the original method.
    # This is primarily used with probes.
    #
    #   obj = Object.new
    #   def obj.foobar
    #     yield(1)
    #   end
    #   mock(obj).method_name.implemented_by_original_method
    #   obj.foobar {|arg| puts arg} # puts 1
    def implemented_by_original_method
      implemented_by ORIGINAL_METHOD
      self
    end

    # Scenario#call calls the Scenario's implementation. The return
    # value of the implementation is returned.
    #
    # A TimesCalledError is raised when the times called
    # exceeds the expected TimesCalledExpectation.
    def call(double, *args, &block)
      @times_called_expectation.attempt! if @times_called_expectation
      @space.verify_ordered_scenario(self) if ordered?
      yields!(block)
      return_value = call_implementation(double, *args, &block)
      return return_value unless @after_call
      @after_call.call(return_value)
    end

    def yields!(block)
      if @yields
        unless block
          raise ArgumentError, "A Block must be passed into the method call when using yields"
        end
        block.call(*@yields)
      end
    end
    protected :yields!

    def call_implementation(double, *args, &block)
      return nil unless @implementation

      if @implementation === ORIGINAL_METHOD
        if !double.original_method
          raise Errors::ScenarioDefinitionError,
                "implemented_by_original_method (probe) cannot be used when method does not exist on the object"
        end
        return double.original_method.call(*args, &block)
      end

      if @implementation.is_a?(Method)
        return @implementation.call(*args, &block)
      else
        args << block if block
        return @implementation.call(*args)
      end
    end
    protected :call_implementation

    # Scenario#exact_match? returns true when the passed in arguments
    # exactly match the ArgumentEqualityExpectation arguments.
    def exact_match?(*arguments)
      return false unless @argument_expectation
      @argument_expectation.exact_match?(*arguments)
    end

    # Scenario#wildcard_match? returns true when the passed in arguments
    # wildcard match the ArgumentEqualityExpectation arguments.
    def wildcard_match?(*arguments)
      return false unless @argument_expectation
      @argument_expectation.wildcard_match?(*arguments)
    end

    # Scenario#attempt? returns true when the
    # TimesCalledExpectation is satisfied.
    def attempt?
      return true unless @times_called_expectation
      @times_called_expectation.attempt?
    end

    # Scenario#verify verifies the the TimesCalledExpectation
    # is satisfied for this scenario. A TimesCalledError
    # is raised if the TimesCalledExpectation is not met.
    def verify
      return true unless @times_called_expectation
      @times_called_expectation.verify!
      true
    end

    def terminal?
      return false unless @times_called_expectation
      @times_called_expectation.terminal?
    end

    # The method name that this Scenario is attatched to
    def method_name
      double.method_name
    end

    # The Arguments that this Scenario expects
    def expected_arguments
      return [] unless argument_expectation
      argument_expectation.expected_arguments
    end

    # The TimesCalledMatcher for the TimesCalledExpectation
    def times_matcher
      times_called_expectation.matcher
    end
  end
end
