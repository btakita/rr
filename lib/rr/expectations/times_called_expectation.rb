module RR
  module Expectations
    class TimesCalledExpectation
      attr_reader :matcher, :times_called
      
      def initialize(matcher=nil, &time_condition_block)
        raise ArgumentError, "Cannot pass in both an argument and a block" if matcher && time_condition_block
        @matcher = matcher || time_condition_block
        if @matcher.is_a?(Integer)
          @matcher = TimesCalledMatchers::IntegerMatcher.new(@matcher)
        elsif @matcher.is_a?(Range)
          @matcher = TimesCalledMatchers::RangeMatcher.new(@matcher)
        end
        @times_called = 0
        @verify_backtrace = caller[1..-1]
      end

      def attempt!
        @times_called += 1
        if(
          @matcher.is_a?(TimesCalledMatchers::TimesCalledMatcher) &&
          !@matcher.possible_match?(@times_called)
        )
          verify_input_error
        end
        verify_input_error if @matcher.is_a?(Range) && @times_called > @matcher.end
        return
      end

      def verify
        return @matcher.matches?(@times_called) if @matcher.is_a?(TimesCalledMatchers::TimesCalledMatcher)
        return true if @matcher.is_a?(Proc) && @matcher.call(@times_called)
        return true if @matcher.is_a?(Range) && @matcher.include?(@times_called)
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
        if @matcher.is_a?(TimesCalledMatchers::TimesCalledMatcher)
          @matcher.error_message(@times_called)
        else
          time_casing = (@times_called == 1) ? "time" : "times"
          "Called #{@times_called.inspect} #{time_casing}. Expected #{@matcher.inspect}."
        end
      end
    end
  end
end