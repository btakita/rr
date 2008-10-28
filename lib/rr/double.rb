module RR
  # RR::Double is the use case for a method call.
  # It has the ArgumentEqualityExpectation, TimesCalledExpectation,
  # and the implementation.
  class Double
    class << self
      def formatted_name(method_name, args)
        formatted_errors = args.collect {|arg| arg.inspect}.join(', ')
        "#{method_name}(#{formatted_errors})"
      end

      def list_message_part(doubles)
        doubles.collect do |double|
          "- #{formatted_name(double.method_name, double.expected_arguments)}"
        end.join("\n")
      end
    end

    attr_reader :times_called, :double_injection, :definition
    include Space::Reader

    def initialize(double_injection, definition)
      @double_injection = double_injection
      @definition = definition
      @times_called = 0
      @times_called_expectation = Expectations::TimesCalledExpectation.new(self)
      definition.double = self
      double_injection.register_double self
    end

    # Double#with sets the expectation that the Double will receive
    # the passed in arguments.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.with(1, 2) {:return_value}
    def with(*args, &returns)
      definition.with(*args, &returns)
    end

    # Double#with_any_args sets the expectation that the Double can receive
    # any arguments.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.with_any_args {:return_value}
    def with_any_args(&returns)
      definition.with_any_args(&returns)
    end

    # Double#with_no_args sets the expectation that the Double will receive
    # no arguments.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.with_no_args {:return_value}
    def with_no_args(&returns)
      definition.with_no_args(&returns)
    end

    # Double#never sets the expectation that the Double will never be
    # called.
    #
    # This method does not accept a block because it will never be called.
    #
    #   mock(subject).method_name.never
    def never
      definition.never
    end

    # Double#once sets the expectation that the Double will be called
    # 1 time.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.once {:return_value}
    def once(&returns)
      definition.once(&returns)
    end

    # Double#twice sets the expectation that the Double will be called
    # 2 times.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.twice {:return_value}
    def twice(&returns)
      definition.twice(&returns)
    end

    # Double#at_least sets the expectation that the Double
    # will be called at least n times.
    # It works by creating a TimesCalledExpectation.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.at_least(4) {:return_value}
    def at_least(number, &returns)
      definition.at_least(number, &returns)
    end

    # Double#at_most allows sets the expectation that the Double
    # will be called at most n times.
    # It works by creating a TimesCalledExpectation.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.at_most(4) {:return_value}
    def at_most(number, &returns)
      definition.at_most(number, &returns)
    end

    # Double#any_number_of_times sets an that the Double will be called
    # any number of times. This effectively removes the times called expectation
    # from the Doublen
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.any_number_of_times
    def any_number_of_times(&returns)
      definition.any_number_of_times(&returns)
    end

    # Double#times creates an TimesCalledExpectation of the passed
    # in number.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.times(4) {:return_value}
    def times(number, &returns)
      definition.times(number, &returns)
    end

    # Double#ordered sets the Double to have an ordered
    # expectation.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.ordered {return_value}
    def ordered(&returns)
      definition.ordered(&returns)
    end

    # Double#ordered? returns true when the Double is ordered.
    #
    #   mock(subject).method_name.ordered?
    def ordered?
      definition.ordered?
    end

    # Double#verbose sets the Double to print out each method call it receives.
    #
    # Passing in a block sets the return value
    def verbose(&block)
      definition.verbose(&block)
    end

    # Double#verbose? returns true when verbose has been called on it. It returns
    # true when the double is set to print each method call it receives.
    def verbose?
      definition.verbose?
    end

    # Double#yields sets the Double to invoke a passed in block when
    # the Double is called.
    # An Expection will be raised if no block is passed in when the
    # Double is called.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.yields(yield_arg1, yield_arg2) {return_value}
    #   subject.method_name {|yield_arg1, yield_arg2|}
    def yields(*args, &returns)
      definition.yields(*args, &returns)
    end

    # Double#after_call creates a callback that occurs after call
    # is called. The passed in block receives the return value of
    # the Double being called.
    # An Expection will be raised if no block is passed in.
    #
    #   mock(subject).method_name {return_value}.after_call {|return_value|}
    #   subject.method_name # return_value
    #
    # This feature is built into proxies.
    #   mock.proxy(User).find('1') {|user| mock(user).valid? {false}}
    def after_call(&block)
      definition.after_call &block
    end

    # Double#returns accepts an argument value or a block.
    # It will raise an ArgumentError if both are passed in.
    #
    # Passing in a block causes Double to return the return value of
    # the passed in block.
    #
    # Passing in an argument causes Double to return the argument.
    def returns(*args, &implementation)
      definition.returns(*args, &implementation)
    end

    # Double#implemented_by sets the implementation of the Double.
    # This method takes a Proc or a Method. Passing in a Method allows
    # the Double to accept blocks.
    #
    #   obj = Object.new
    #   def obj.foobar
    #     yield(1)
    #   end
    #   mock(obj).method_name.implemented_by(obj.method(:foobar))
    def implemented_by(implementation)
      definition.implemented_by implementation
    end

    # Double#call calls the Double's implementation. The return
    # value of the implementation is returned.
    #
    # A TimesCalledError is raised when the times called
    # exceeds the expected TimesCalledExpectation.
    def call(double_injection, *args, &block)
      if verbose?
        puts Double.formatted_name(double_injection.method_name, args)
      end
      times_called_expectation.attempt if definition.times_matcher
      space.verify_ordered_double(self) if ordered?
      yields!(block)
      return_value = call_implementation(double_injection, *args, &block)
      definition.after_call_proc ? extract_subject_from_return_value(definition.after_call_proc.call(return_value)) : return_value
    end

    def yields!(block)
      if definition.yields_value
        if block
          block.call(*definition.yields_value)
        else
          raise ArgumentError, "A Block must be passed into the method call when using yields"
        end
      end
    end
    protected :yields!

    def call_implementation(double_injection, *args, &block)
      return_value = do_call_implementation_and_get_return_value(double_injection, *args, &block)
      extract_subject_from_return_value(return_value)
    end
    protected :call_implementation

    # Double#exact_match? returns true when the passed in arguments
    # exactly match the ArgumentEqualityExpectation arguments.
    def exact_match?(*arguments)
      definition.exact_match?(*arguments)
    end

    # Double#wildcard_match? returns true when the passed in arguments
    # wildcard match the ArgumentEqualityExpectation arguments.
    def wildcard_match?(*arguments)
      definition.wildcard_match?(*arguments)
    end

    # Double#attempt? returns true when the
    # TimesCalledExpectation is satisfied.
    def attempt?
      return true unless definition.times_matcher
      times_called_expectation.attempt?
    end

    # Double#verify verifies the the TimesCalledExpectation
    # is satisfied for this double. A TimesCalledError
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

    # The method name that this Double is attatched to
    def method_name
      double_injection.method_name
    end

    # The Arguments that this Double expects
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

    def formatted_name
      self.class.formatted_name(method_name, expected_arguments)
    end

    protected
    def do_call_implementation_and_get_return_value(double_injection, *args, &block)
      if definition.implementation_is_original_method?
        if double_injection.object_has_original_method?
          double_injection.call_original_method(*args, &block)
        else
          double_injection.subject.__send__(
            :method_missing,
            method_name,
            *args,
            &block
          )
        end
      else
        if implementation
          if implementation.is_a?(Method)
            implementation.call(*args, &block)
          else
            args << block if block
            implementation.call(*args)
          end
        else
          nil
        end
      end
    end

    def extract_subject_from_return_value(return_value)
      case return_value
      when DoubleDefinitions::DoubleDefinition
        return_value.root_subject
      when DoubleDefinitions::DoubleDefinitionCreatorProxy
        return_value.__creator__.root_subject
      else
        return_value
      end
    end
  end
end
