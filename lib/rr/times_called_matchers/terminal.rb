module RR
module TimesCalledMatchers
  # Including this module marks the TimesCalledMatcher as Terminal.
  # Being Terminal means the attempt? method will eventually return
  # false.
  #
  # The Scenario that uses a Terminal TimesCalledMatcher will
  # eventually be passed over to the next Scenario when passed
  # the matching arguments enough times.
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