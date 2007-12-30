module RR
  module TimesCalledMatchers
    # Including this module marks the TimesCalledMatcher as NonTerminal.
    # Being NonTerminal means the Double will not "terminate" even when
    # called infinite times.
    #
    # The Double that uses a NonTerminal TimesCalledMatcher will
    # continue using the Double when passed the matching arguments.
    # This is done by the attempt? always returning true.
    #
    # This is in opposition to Terminal TimesCalledMatchers, where
    # attempt? will eventually return false.
    module NonTerminal #:nodoc:
      def terminal?
        false
      end

      def possible_match?(times_called)
        true
      end

      def attempt?(times_called)
        true
      end
    end
  end
end