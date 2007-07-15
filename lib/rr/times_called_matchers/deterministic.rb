module RR
module TimesCalledMatchers
  # Including this module marks the TimesCalledMatcher as Deterministic.
  # Being Deterministic means the attempt? method will eventually return
  # false.
  #
  # The Scenario that uses a Deterministic TimesCalledMatcher will
  # eventually be passed over to the next Scenario when passed
  # the matching arguments enough times.
  #
  # This is in opposition to NonDeterministic TimesCalledMatchers, where
  # attempt? will always return true.
  module Deterministic
    def deterministic?
      true
    end
  end
end
end