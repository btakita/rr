module RR
  module TimesCalledMatchers #:nodoc:
    class AnyTimesMatcher < TimesCalledMatcher
      include NonTerminal

      def initialize
      end

      def matches?(times_called)
        true
      end

      def expected_times_message
        "any number of times"
      end
    end
  end
end