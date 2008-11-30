module RR
  module TimesCalledMatchers #:nodoc:
    class AtLeastMatcher < TimesCalledMatcher
      include NonTerminal

      def matches?(times_called)
        times_called >= @times
      end

      def expected_times_message
        "at least #{@times.inspect} times"
      end
    end
  end
end