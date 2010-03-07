module RR
  module TimesCalledMatchers #:nodoc:
    class NeverMatcher < TimesCalledMatcher
      include Terminal

      def initialize
        super 0
      end

      def possible_match?(times_called)
        true
      end

      def matches?(times_called)
        true
      end

      def attempt?(times_called)
        raise RR::Errors::TimesCalledError, error_message(1)
      end
    end
  end
end