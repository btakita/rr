module RR
module TimesCalledMatchers
  # Including this module marks the TimesCalledMatcher as NonTerminal.
  # Being NonTerminal means the attempt? method will always return
  # true.
  #
  # The Scenario that uses a NonTerminal TimesCalledMatcher will
  # continue using the Scenario when passed the matching arguments.
  #
  # This is in opposition to Terminal TimesCalledMatchers, where
  # attempt? will eventually return false.
  module NonTerminal
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