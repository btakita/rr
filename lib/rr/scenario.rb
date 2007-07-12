module RR
  # RR::Scenario is the use case for a method call.
  # It has the ArgumentEqualityError, TimesCalledExpectation,
  # and the implementation.
  class Scenario
    attr_reader :times_called, :argument_expectation, :times_called_expectation

    def initialize(space)
      @space = space
      @implementation = nil
      @argument_expectation = nil
      @times_called_expectation = nil
      @times_called = 0
      @after_call = nil
      @yields = nil
    end

    # Scenario#with creates an ArgumentEqualityError for the
    # Scenario. it takes a list of expected arguments.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.with(1, 2) {:return_value}
    def with(*args, &returns)
      @argument_expectation = Expectations::ArgumentEqualityError.new(*args)
      returns(&returns) if returns
      self
    end

    # Scenario#with_any_args creates an AnyArgumentEqualityError
    # for the Scenario.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.with_any_args {:return_value}
    def with_any_args(&returns)
      @argument_expectation = Expectations::AnyArgumentExpectation.new
      returns(&returns) if returns
      self
    end

    # Scenario#with_no_args creates an ArgumentEqualityError with
    # no arguments for the Scenario.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.with_no_args {:return_value}
    def with_no_args(&returns)
      @argument_expectation = Expectations::ArgumentEqualityError.new()
      returns(&returns) if returns
      self
    end

    # Scenario#never creates an TimesCalledExpectation of 0.
    #
    # This method does not accept a block because it will never be called.
    #
    #   mock(subject).method_name.never
    def never
      @times_called_expectation = Expectations::TimesCalledExpectation.new(0)
      self
    end

    # Scenario#once creates an TimesCalledExpectation of 1.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.once {:return_value}
    def once(&returns)
      @times_called_expectation = Expectations::TimesCalledExpectation.new(1)
      returns(&returns) if returns
      self
    end

    # Scenario#twice creates an TimesCalledExpectation of 2.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.twice {:return_value}
    def twice(&returns)
      @times_called_expectation = Expectations::TimesCalledExpectation.new(2)
      returns(&returns) if returns
      self
    end

    # Scenario#at_least allows you to set an expectation that the Scenario
    # will be called at least n times.
    # It works by creating a TimesCalledExpectation.
    #
    # Passing in a block sets the return value.
    #
    #   mock(subject).method_name.at_least(4) {:return_value}
    def at_least(number, &returns)
      matcher = RR::Expectations::TimesCalledMatchers::AtLeastMatcher.new(number)
      @times_called_expectation = Expectations::TimesCalledExpectation.new(matcher)
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
      raise ArgumentError, "returns cannot accept both an argument and a block" if value && implementation
      if value
        implemented_by proc {value}
      else
        implemented_by implementation
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

    # Scenario#call calls the Scenario's implementation. The return
    # value of the implementation is returned.
    #
    # A TimesCalledError is raised when the times called
    # exceeds the expected TimesCalledExpectation.
    def call(*args, &block)
      return_value = call_implementation(*args, &block)
      @after_call.call(return_value) if @after_call
      return_value
    end

    def call_implementation(*args, &block)
      @times_called_expectation.verify_input if @times_called_expectation
      @space.verify_ordered_scenario(self) if ordered?
      if @yields
        unless block
          raise ArgumentError, "A Block must be passed into the method call when using yields"
        end
        block.call(*@yields)
      end
      return nil unless @implementation

      if @implementation.is_a?(Method)
        return @implementation.call(*args, &block)
      else
        args << block if block
        return @implementation.call(*args)
      end
    end
    protected :call_implementation

    # Scenario#exact_match? returns true when the passed in arguments
    # exactly match the ArgumentEqualityError arguments.
    def exact_match?(*arguments)
      return false unless @argument_expectation 
      @argument_expectation.exact_match?(*arguments)
    end

    # Scenario#wildcard_match? returns true when the passed in arguments
    # wildcard match the ArgumentEqualityError arguments.
    def wildcard_match?(*arguments)
      return false unless @argument_expectation
      @argument_expectation.wildcard_match?(*arguments)
    end

    # Scenario#times_called_verified? returns true when the
    # TimesCalledExpectation is satisfied.
    def times_called_verified?
      return false unless @times_called_expectation
      @times_called_expectation.verify
    end

    # Scenario#verify verifies the the TimesCalledExpectation
    # is satisfied for this scenario. A TimesCalledError
    # is raised if the TimesCalledExpectation is not met.
    def verify
      return true unless @times_called_expectation
      @times_called_expectation.verify!
      true
    end
  end
end