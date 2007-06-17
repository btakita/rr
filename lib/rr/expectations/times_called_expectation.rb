module RR
  module Expectations
    class TimesCalledExpectationError < RuntimeError
    end
    
    class TimesCalledExpectation < Expectation
      attr_reader :times, :times_called
      
      def initialize(times=nil, &time_condition_block)
        raise ArgumentError, "Cannot pass in both an argument and a block" if times && time_condition_block
        @times = times || time_condition_block
        @times_called = 0
      end

      def verify_input(*args)
        @times_called += 1
        verify_input_error if @times.is_a?(Integer) && @times_called > @times
        verify_input_error if @times.is_a?(Range) && @times_called > @times.end
        return
      end

      def verify(double)
        return if @times.is_a?(Integer) && @times == double.times_called
        return if @times.is_a?(Proc) && @times.call(double.times_called)
        return if @times.is_a?(Range) && @times.include?(double.times_called)
        raise TimesCalledExpectationError
      end

      protected
      def verify_input_error
        raise TimesCalledExpectationError, "Called #{@times_called.inspect} times. Expected #{@times.inspect}"
      end
    end
  end
end