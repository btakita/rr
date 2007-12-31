require "spec/spec_helper"

module RR
  describe DoubleInjection, "#register_scenario" do
    before do
      @space = Space.new
      @object = Object.new
      @method_name = :foobar
      @object.methods.should_not include(@method_name.to_s)
      @double_insertion = DoubleInjection.new(@space, @object, @method_name)
      def @double_insertion.scenarios
        @scenarios
      end
    end

    it "adds the scenario to the scenarios list" do
      scenario = Double.new(@space, @double_insertion, @space.scenario_definition)

      @double_insertion.scenarios.should_not include(scenario)
      @double_insertion.register_scenario scenario
      @double_insertion.scenarios.should include(scenario)
    end
  end
end
