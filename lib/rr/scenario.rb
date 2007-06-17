module RR
  class Scenario
    attr_reader :double

    def initialize(double)
      @double = double
      @implementation = nil
      @argument_expectation = nil
      @times_called_expectation = nil
      @double.scenarios << self
    end

    def with(*args)
      @argument_expectation = Expectations::ArgumentEqualityExpectation.new(*args)
      @double.add_expectation @argument_expectation
      self
    end

    def once
      @times_called_expectation = Expectations::TimesCalledExpectation.new(1)
      @double.add_expectation @times_called_expectation
      self
    end

    def twice
      @times_called_expectation = Expectations::TimesCalledExpectation.new(2)
      @double.add_expectation @times_called_expectation
      self
    end

    def times(number)
      @times_called_expectation = Expectations::TimesCalledExpectation.new(number)
      @double.add_expectation @times_called_expectation
      self
    end

    def returns(&implementation)
      @implementation = implementation
      @double.double_method = implementation
      self
    end

    def original_method
      @double.original_method
    end

    def call(*args)
      @implementation.call(*args)
    end

    def exact_match?(*arguments)
      @argument_expectation.exact_match?(*arguments)
    end

    def wildcard_match?(*arguments)
      @argument_expectation.wildcard_match?(*arguments)
    end    
  end
end