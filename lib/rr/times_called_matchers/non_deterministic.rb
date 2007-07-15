module RR
module TimesCalledMatchers
  # Including this module marks the TimesCalledMatcher as NonDeterministic.
  # Being NonDeterministic means the attempt? method will always return
  # true.
  #
  # The Scenario that uses a NonDeterministic TimesCalledMatcher will
  # continue using the Scenario when passed the matching arguments.
  #
  # This is in opposition to Deterministic TimesCalledMatchers, where
  # attempt? will eventually return false.
  module NonDeterministic
    def deterministic?
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