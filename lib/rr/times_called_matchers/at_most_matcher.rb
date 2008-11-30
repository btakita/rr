module RR
  module TimesCalledMatchers #:nodoc:
    class AtMostMatcher < TimesCalledMatcher
      include Terminal

      def possible_match?(times_called)
        times_called <= @times
      end

      def matches?(times_called)
        times_called <= @times
      end

      def attempt?(times_called)
        times_called < @times
      end

      def expected_times_message
        "at most #{@times.inspect} times"
      end
    end
  end
end