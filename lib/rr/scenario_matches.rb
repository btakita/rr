module RR
class ScenarioMatches
  attr_reader :matching_scenarios,
              :exact_terminal_scenarios_to_attempt,
              :exact_non_terminal_scenarios_to_attempt,
              :wildcard_terminal_scenarios_to_attempt,
              :wildcard_non_terminal_scenarios_to_attempt
  def initialize(scenarios)
    @scenarios = scenarios
    @matching_scenarios = []
    @exact_terminal_scenarios_to_attempt = []
    @exact_non_terminal_scenarios_to_attempt = []
    @wildcard_terminal_scenarios_to_attempt = []
    @wildcard_non_terminal_scenarios_to_attempt = []
  end

  def match(args)
    @scenarios.each do |scenario|
      if scenario.exact_match?(*args)
        matching_scenarios << scenario
        if scenario.attempt?
          if scenario.terminal?
            exact_terminal_scenarios_to_attempt << scenario
          else
            exact_non_terminal_scenarios_to_attempt << scenario
          end
        end
      elsif scenario.wildcard_match?(*args)
        matching_scenarios << scenario
        if scenario.attempt?
          if scenario.terminal?
            wildcard_terminal_scenarios_to_attempt << scenario
          else
            wildcard_non_terminal_scenarios_to_attempt << scenario
          end
        end
      end
    end
    self
  end
end
end