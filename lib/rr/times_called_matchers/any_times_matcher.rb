module RR
  module TimesCalledMatchers #:nodoc:
    class AnyTimesMatcher < TimesCalledMatcher
      include NonTerminal

      def initialize
      end

      def matches?(times_called)
        true
      end

      protected
      def expected_message_part
        "Expected any number of times."
      end
    end
  end
end