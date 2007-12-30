module RR
class DoubleMatches
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

  def find_all_matches!(args)
    @scenarios.each do |scenario|
      if scenario.exact_match?(*args)
        matching_scenarios << scenario
        if scenario.attempt?
          exact_scenario_is_terminal_or_non_terminal scenario
        end
      elsif scenario.wildcard_match?(*args)
        matching_scenarios << scenario
        if scenario.attempt?
          wildcard_scenario_is_terminal_or_non_terminal scenario
        end
      end
    end
    self
  end

  protected
  def exact_scenario_is_terminal_or_non_terminal(scenario)
    if scenario.terminal?
      exact_terminal_scenarios_to_attempt << scenario
    else
      exact_non_terminal_scenarios_to_attempt << scenario
    end
  end

  def wildcard_scenario_is_terminal_or_non_terminal(scenario)
    if scenario.terminal?
      wildcard_terminal_scenarios_to_attempt << scenario
    else
      wildcard_non_terminal_scenarios_to_attempt << scenario
    end
  end
end
end