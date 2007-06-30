dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
describe Double, "#register_scenario" do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    @object.methods.should_not include(@method_name.to_s)
    @double = Double.new(@space, @object, @method_name)
    def @double.scenarios
      @scenarios
    end
  end
  
  it "adds the scenario to the scenarios list" do
    scenario = Scenario.new(@space)

    @double.scenarios.should_not include(scenario)
    @double.register_scenario scenario
    @double.scenarios.should include(scenario)
  end
end
end
