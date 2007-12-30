module RR
  module TimesCalledMatchers #:nodoc:
    class AtLeastMatcher < TimesCalledMatcher
      include NonTerminal

      def matches?(times_called)
        times_called >= @times
      end

      protected
      def expected_message_part
        "Expected at least #{@times.inspect} times."
      end
    end
  end
end