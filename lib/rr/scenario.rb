module RR
  class Scenario
    attr_reader :double, :times_called, :argument_expectation, :times_called_expectation

    def initialize(double)
      @double = double
      @implementation = nil
      @argument_expectation = nil
      @times_called_expectation = nil
      @double.scenarios << self
      @times_called = 0
    end

    def with(*args)
      @argument_expectation = Expectations::ArgumentEqualityExpectation.new(*args)
      self
    end

    def with_any_args
      @argument_expectation = Expectations::ArgumentEqualityExpectation.new(Expectations::ArgumentEqualityExpectation::Anything.new)
      self
    end

    def once
      @times_called_expectation = Expectations::TimesCalledExpectation.new(1)
      self
    end

    def twice
      @times_called_expectation = Expectations::TimesCalledExpectation.new(2)
      self
    end

    def times(number)
      @times_called_expectation = Expectations::TimesCalledExpectation.new(number)
      self
    end

    def returns(&implementation)
      @implementation = implementation
      self
    end

    def original_method
      @double.original_method
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
      @argument_expectation.wildcard_match?(*arguments)
    end

    def verify
      return true unless @times_called_expectation
      @times_called_expectation.verify
      true
    end
  end
end