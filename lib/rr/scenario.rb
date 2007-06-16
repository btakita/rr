module RR
  class Scenario
    attr_reader :double

    def initialize(double)
      @double = double
    end

    def with(*args)
      @double.add_expectation Expectations::ArgumentEqualityExpectation.new(*args)
      self
    end

    def once
      @double.add_expectation Expectations::TimesCalledExpectation.new(1)
      self
    end

    def twice
      @double.add_expectation Expectations::TimesCalledExpectation.new(2)
      self
    end

    def times(number)
      @double.add_expectation Expectations::TimesCalledExpectation.new(number)
      self
    end

    def returns(&implementation)
      @double.double_method = implementation
      self
    end

    def original_method
      @double.original_method
    end
    
  end
end