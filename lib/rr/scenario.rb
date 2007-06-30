module RR
  class Scenario
    attr_reader :times_called, :argument_expectation, :times_called_expectation

    def initialize(space)
      @space = space
      @implementation = nil
      @argument_expectation = nil
      @times_called_expectation = nil
      @times_called = 0
    end

    def with(*args, &returns)
      @argument_expectation = Expectations::ArgumentEqualityExpectation.new(*args)
      returns(&returns) if returns
      self
    end

    def with_any_args(&returns)
      @argument_expectation = Expectations::AnyArgumentExpectation.new
      returns(&returns) if returns
      self
    end

    def once(&returns)
      @times_called_expectation = Expectations::TimesCalledExpectation.new(1)
      returns(&returns) if returns
      self
    end

    def twice(&returns)
      @times_called_expectation = Expectations::TimesCalledExpectation.new(2)
      returns(&returns) if returns
      self
    end

    def times(number, &returns)
      @times_called_expectation = Expectations::TimesCalledExpectation.new(number)
      returns(&returns) if returns
      self
    end

    def returns(&implementation)
      @implementation = implementation
      self
    end

    def call(*args)
      @times_called_expectation.verify_input if @times_called_expectation
      if @implementation
        return @implementation.call(*args)
      else
        return nil
      end
    end

    def exact_match?(*arguments)
      return false unless @argument_expectation 
      @argument_expectation.exact_match?(*arguments)
    end

    def wildcard_match?(*arguments)
      return false unless @argument_expectation
      @argument_expectation.wildcard_match?(*arguments)
    end

    def times_called_verified?
      @times_called_expectation.verify
    end

    def verify
      return true unless @times_called_expectation
      @times_called_expectation.verify!
      true
    end
  end
end