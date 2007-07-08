module RR
  module Expectations
    class TimesCalledExpectation
      attr_reader :times, :times_called
      
      def initialize(times=nil, &time_condition_block)
        raise ArgumentError, "Cannot pass in both an argument and a block" if times && time_condition_block
        @times = times || time_condition_block
        @times_called = 0
      end

      def verify_input
        @times_called += 1
        verify_input_error if @times.is_a?(Integer) && @times_called > @times
        verify_input_error if @times.is_a?(Range) && @times_called > @times.end
        return
      end

      def verify
        return true if @times.is_a?(Integer) && @times == @times_called
        return true if @times.is_a?(Proc) && @times.call(@times_called)
        return true if @times.is_a?(Range) && @times.include?(@times_called)
        return false
      end

      def verify!
        raise Errors::TimesCalledError unless verify
      end

      protected
      def verify_input_error
        raise Errors::TimesCalledError, "Called #{@times_called.inspect} times. Expected #{@times.inspect}"
      end
    end
  end
end