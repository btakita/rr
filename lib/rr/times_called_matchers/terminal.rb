module RR
module TimesCalledMatchers
  # Including this module marks the TimesCalledMatcher as Terminal.
  # Being Terminal the Scenario will "terminate" when times called is
  # finite.
  #
  # The Scenario that uses a Terminal TimesCalledMatcher will
  # eventually be passed over to the next Scenario when passed
  # the matching arguments enough times. This is done by the attempt?
  # method returning false when executed a finite number of times.
  #
  # This is in opposition to NonTerminal TimesCalledMatchers, where
  # attempt? will always return true.
  module Terminal
    def terminal?
      true
    end
  end
end
end