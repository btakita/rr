module RR
  module Expectations
    class TimesCalledExpectation
      attr_reader :times, :times_called
      
      def initialize(times=nil, &time_condition_block)
        raise ArgumentError, "Cannot pass in both an argument and a block" if times && time_condition_block
        @times = times || time_condition_block
        @times_called = 0
        @verify_backtrace = caller[1..-1]
      end

      def verify_input
        @times_called += 1
        if(
          @times.is_a?(TimesCalledMatchers::TimesCalledMatcher) &&
          !@times.possible_match?(@times_called)
        )
          verify_input_error
        end
        verify_input_error if @times.is_a?(Integer) && @times_called > @times
        verify_input_error if @times.is_a?(Range) && @times_called > @times.end
        return
      end

      def verify
        return @times.matches?(@times_called) if @times.is_a?(TimesCalledMatchers::TimesCalledMatcher)
        return true if @times.is_a?(Integer) && @times == @times_called
        return true if @times.is_a?(Proc) && @times.call(@times_called)
        return true if @times.is_a?(Range) && @times.include?(@times_called)
        return false
      end

      def verify!
        unless verify
          if @verify_backtrace
            error = Errors::TimesCalledError.new(error_message)
            error.backtrace = @verify_backtrace
            raise error
          else
            raise Errors::TimesCalledError, error_message
          end
        end
      end

      protected
      def verify_input_error
        raise Errors::TimesCalledError, error_message
      end

      def error_message
        if @times.is_a?(TimesCalledMatchers::TimesCalledMatcher)
          @times.error_message(@times_called)
        else
          time_casing = (@times_called == 1) ? "time" : "times"
          "Called #{@times_called.inspect} #{time_casing}. Expected #{@times.inspect}."
        end
      end
    end
  end
end