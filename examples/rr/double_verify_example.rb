dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
describe Double, "#verify" do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    @object.methods.should_not include(@method_name.to_s)
    @double = @space.create_double(@object, @method_name) {}
  end

  it "verifies each scenario was met" do
    scenario = Scenario.new
    @double.register_scenario scenario
    
    scenario.with(1).once.returns {nil}
    proc {@double.verify}.should raise_error(Expectations::TimesCalledExpectationError)
    @object.foobar(1)
    proc {@double.verify}.should_not raise_error
  end
end
end
