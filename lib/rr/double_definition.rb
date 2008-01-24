module RR
  # RR::Double is the use case for a method call.
  # It has the ArgumentEqualityExpectation, TimesCalledExpectation,
  # and the implementation.
  class DoubleDefinition #:nodoc:
    ORIGINAL_METHOD = Object.new
    attr_accessor :times_called,
                  :argument_expectation,
                  :times_matcher,
                  :implementation,
                  :after_call_value,
                  :yields_value,
                  :double
    attr_reader   :block_callback_strategy

    def initialize(space)
      @space = space
      @implementation = nil
      @argument_expectation = nil
      @times_matcher = nil
      @after_call_value = nil
      @yields_value = nil
      returns_block_callback_strategy!
    end

    # Double#with sets the expectation that the Double will receive
    # the passed in arguments.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.with(1, 2) {:return_value}
    def with(*args, &returns)
      @argument_expectation = Expectations::ArgumentEqualityExpectation.new(*args)
      install_method_callback returns
      self
    end

    # Double#with_any_args sets the expectation that the Double can receive
    # any arguments.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.with_any_args {:return_value}
    def with_any_args(&returns)
      @argument_expectation = Expectations::AnyArgumentExpectation.new
      install_method_callback returns
      self
    end

    # Double#with_no_args sets the expectation that the Double will receive
    # no arguments.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.with_no_args {:return_value}
    def with_no_args(&returns)
      @argument_expectation = Expectations::ArgumentEqualityExpectation.new()
      install_method_callback returns
      self
    end

    # Double#never sets the expectation that the Double will never be
    # called.
    #
    # This method does not accept a block because it will never be called.
    #
    #   mock(subject).method_name.never
    def never
      @times_matcher = TimesCalledMatchers::IntegerMatcher.new(0)
      self
    end

    # Double#once sets the expectation that the Double will be called
    # 1 time.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.once {:return_value}
    def once(&returns)
      @times_matcher = TimesCalledMatchers::IntegerMatcher.new(1)
      install_method_callback returns
      self
    end

    # Double#twice sets the expectation that the Double will be called
    # 2 times.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.twice {:return_value}
    def twice(&returns)
      @times_matcher = TimesCalledMatchers::IntegerMatcher.new(2)
      install_method_callback returns
      self
    end

    # Double#at_least sets the expectation that the Double
    # will be called at least n times.
    # It works by creating a TimesCalledExpectation.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.at_least(4) {:return_value}
    def at_least(number, &returns)
      @times_matcher = TimesCalledMatchers::AtLeastMatcher.new(number)
      install_method_callback returns
      self
    end

    # Double#at_most allows sets the expectation that the Double
    # will be called at most n times.
    # It works by creating a TimesCalledExpectation.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.at_most(4) {:return_value}
    def at_most(number, &returns)
      @times_matcher = TimesCalledMatchers::AtMostMatcher.new(number)
      install_method_callback returns
      self
    end

    # Double#any_number_of_times sets an that the Double will be called
    # any number of times. This effectively removes the times called expectation
    # from the Doublen
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.any_number_of_times
    def any_number_of_times(&returns)
      @times_matcher = TimesCalledMatchers::AnyTimesMatcher.new
      install_method_callback returns
      self
    end

    # Double#times creates an TimesCalledExpectation of the passed
    # in number.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.times(4) {:return_value}
    def times(matcher_value, &returns)
      @times_matcher = TimesCalledMatchers::TimesCalledMatcher.create(matcher_value)
      install_method_callback returns
      self
    end

    # Double#ordered sets the Double to have an ordered
    # expectation.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.ordered {return_value}
    def ordered(&returns)
      raise(
        Errors::DoubleDefinitionError,
        "Double Definitions must have a dedicated Double to be ordered. " <<
        "For example, using instance_of does not allow ordered to be used. " <<
        "proxy the class's #new method instead."
      ) unless @double
      @ordered = true
      @space.ordered_doubles << @double unless @space.ordered_doubles.include?(@double)
      install_method_callback returns
      self
    end

    # Double#ordered? returns true when the Double is ordered.
    #
    #   mock(subject).method_name.ordered?
    def ordered?
      @ordered
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
      @yields_value = args
      install_method_callback returns
      self
    end

    # Double#after_call creates a callback that occurs after call
    # is called. The passed in block receives the return value of
    # the Double being called.
    # An Expection will be raised if no block is passed in.
    #
    #   mock(subject).method_name {return_value}.after_call {|return_value|}
    #   subject.method_name # return_value
    #
    # This feature is built into proxys.
    #   mock.proxy(User).find('1') {|user| mock(user).valid? {false}}
    def after_call(&block)
      raise ArgumentError, "after_call expects a block" unless block
      @after_call_value = block
      self
    end

    # Double#verbose sets the Double to print out each method call it receives.
    #
    # Passing in a block sets the return value
    def verbose(&block)
      @verbose = true
      @after_call_value = block
      self
    end

    # Double#verbose? returns true when verbose has been called on it. It returns
    # true when the double is set to print each method call it receives.
    def verbose?
      @verbose ? true : false
    end

    # Double#returns accepts an argument value or a block.
    # It will raise an ArgumentError if both are passed in.
    #
    # Passing in a block causes Double to return the return value of
    # the passed in block.
    #
    # Passing in an argument causes Double to return the argument.
    def returns(value=nil, &implementation)
      if value && implementation
        raise ArgumentError, "returns cannot accept both an argument and a block"
      end
      if value.nil?
        implemented_by implementation
      else
        implemented_by proc {value}
      end
      self
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
      @implementation = implementation
      self
    end

    # Double#implemented_by_original_method sets the implementation
    # of the Double to be the original method.
    # This is primarily used with proxyies.
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

    # Double#exact_match? returns true when the passed in arguments
    # exactly match the ArgumentEqualityExpectation arguments.
    def exact_match?(*arguments)
      return false unless @argument_expectation
      @argument_expectation.exact_match?(*arguments)
    end

    # Double#wildcard_match? returns true when the passed in arguments
    # wildcard match the ArgumentEqualityExpectation arguments.
    def wildcard_match?(*arguments)
      return false unless @argument_expectation
      @argument_expectation.wildcard_match?(*arguments)
    end

    def terminal?
      return false unless @times_matcher
      @times_matcher.terminal?
    end

    # The Arguments that this Double expects
    def expected_arguments
      return [] unless argument_expectation
      argument_expectation.expected_arguments
    end

    def returns_block_callback_strategy! # :nodoc:
      @block_callback_strategy = :returns
    end

    def after_call_block_callback_strategy! # :nodoc:
      @block_callback_strategy = :after_call
    end

    protected
    def install_method_callback(block)
      return unless block
      case @block_callback_strategy
      when :returns; returns(&block)
      when :after_call; after_call(&block)
      else raise "Unknown block_callback_strategy: #{@block_callback_strategy.inspect}"
      end
    end
  end
end