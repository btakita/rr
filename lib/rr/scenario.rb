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

    attr_reader :times_called, :double, :definition

    def initialize(space, double, definition)
      @space = space
      @double = double
      @definition = definition
      @times_called = 0
      @times_called_expectation = Expectations::TimesCalledExpectation.new
    end

    # Scenario#with sets the expectation that the Scenario will receive
    # the passed in arguments.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.with(1, 2) {:return_value}
    def with(*args, &returns)
      definition.with(*args, &returns)
    end

    # Scenario#with_any_args sets the expectation that the Scenario can receive
    # any arguments.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.with_any_args {:return_value}
    def with_any_args(&returns)
      definition.with_any_args(&returns)
    end

    # Scenario#with_no_args sets the expectation that the Scenario will receive
    # no arguments.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.with_no_args {:return_value}
    def with_no_args(&returns)
      definition.with_no_args(&returns)
    end

    # Scenario#never sets the expectation that the Scenario will never be
    # called.
    #
    # This method does not accept a block because it will never be called.
    #
    #   mock(subject).method_name.never
    def never
      definition.never
    end

    # Scenario#once sets the expectation that the Scenario will be called
    # 1 time.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.once {:return_value}
    def once(&returns)
      definition.once(&returns)
    end

    # Scenario#twice sets the expectation that the Scenario will be called
    # 2 times.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.twice {:return_value}
    def twice(&returns)
      definition.twice(&returns)
    end

    # Scenario#at_least sets the expectation that the Scenario
    # will be called at least n times.
    # It works by creating a TimesCalledExpectation.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.at_least(4) {:return_value}
    def at_least(number, &returns)
      definition.at_least(number, &returns)
    end

    # Scenario#at_most allows sets the expectation that the Scenario
    # will be called at most n times.
    # It works by creating a TimesCalledExpectation.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.at_most(4) {:return_value}
    def at_most(number, &returns)
      definition.at_most(number, &returns)
    end

    # Scenario#any_number_of_times sets an that the Scenario will be called
    # any number of times. This effectively removes the times called expectation
    # from the Scenarion
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.any_number_of_times
    def any_number_of_times(&returns)
      definition.any_number_of_times(&returns)
    end

    # Scenario#times creates an TimesCalledExpectation of the passed
    # in number.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.times(4) {:return_value}
    def times(number, &returns)
      definition.times(number, &returns)
    end

    # Scenario#ordered sets the Scenario to have an ordered
    # expectation.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.ordered {return_value}
    def ordered(&returns)
      definition.ordered(&returns)
    end

    # Scenario#ordered? returns true when the Scenario is ordered.
    #
    #   mock(subject).method_name.ordered?
    def ordered?
      definition.ordered?
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
      definition.yields(*args, &returns)
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
      definition.after_call &block
    end

    # Scenario#returns accepts an argument value or a block.
    # It will raise an ArgumentError if both are passed in.
    #
    # Passing in a block causes Scenario to return the return value of
    # the passed in block.
    #
    # Passing in an argument causes Scenario to return the argument.
    def returns(value=nil, &implementation)
      definition.returns(value, &implementation)
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
      definition.implemented_by implementation
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
      definition.implemented_by_original_method
    end

    # Scenario#call calls the Scenario's implementation. The return
    # value of the implementation is returned.
    #
    # A TimesCalledError is raised when the times called
    # exceeds the expected TimesCalledExpectation.
    def call(double, *args, &block)
      self.times_called_expectation.attempt! if definition.times_matcher
      @space.verify_ordered_scenario(self) if ordered?
      yields!(block)
      return_value = call_implementation(double, *args, &block)
      return return_value unless definition.after_call_value
      definition.after_call_value.call(return_value)
    end

    def yields!(block)
      if definition.yields_value
        unless block
          raise ArgumentError, "A Block must be passed into the method call when using yields"
        end
        block.call(*definition.yields_value)
      end
    end
    protected :yields!

    def call_implementation(double, *args, &block)
      return nil unless implementation

      if implementation === ScenarioDefinition::ORIGINAL_METHOD
        if double.original_method
          return double.original_method.call(*args, &block)
        else
          return double.object.__send__(
            :method_missing,
            double.method_name,
            *args,
            &block
          )
        end
      end

      if implementation.is_a?(Method)
        return implementation.call(*args, &block)
      else
        args << block if block
        return implementation.call(*args)
      end
    end
    protected :call_implementation

    # Scenario#exact_match? returns true when the passed in arguments
    # exactly match the ArgumentEqualityExpectation arguments.
    def exact_match?(*arguments)
      definition.exact_match?(*arguments)
    end

    # Scenario#wildcard_match? returns true when the passed in arguments
    # wildcard match the ArgumentEqualityExpectation arguments.
    def wildcard_match?(*arguments)
      definition.wildcard_match?(*arguments)
    end

    # Scenario#attempt? returns true when the
    # TimesCalledExpectation is satisfied.
    def attempt?
      return true unless definition.times_matcher
      times_called_expectation.attempt?
    end

    # Scenario#verify verifies the the TimesCalledExpectation
    # is satisfied for this scenario. A TimesCalledError
    # is raised if the TimesCalledExpectation is not met.
    def verify
      return true unless definition.times_matcher
      times_called_expectation.verify!
      true
    end

    def terminal?
      return false unless definition.times_matcher
      times_called_expectation.terminal?
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

    def times_called_expectation
      @times_called_expectation.matcher = definition.times_matcher
      @times_called_expectation
    end

    def implementation
      definition.implementation
    end
    def implementation=(value)
      definition.implementation = value
    end
    protected :implementation=

    def argument_expectation
      definition.argument_expectation
    end
    def argument_expectation=(value)
      definition.argument_expectation = value
    end
    protected :argument_expectation=
  end
end
