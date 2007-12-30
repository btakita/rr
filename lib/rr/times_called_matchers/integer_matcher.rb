module RR
  module TimesCalledMatchers #:nodoc:
    class IntegerMatcher < TimesCalledMatcher
      include Terminal

      def possible_match?(times_called)
        times_called <= @times
      end

      def matches?(times_called)
        times_called == @times
      end

      def attempt?(times_called)
        times_called < @times
      end
    end
  end
end