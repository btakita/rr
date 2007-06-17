dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
describe Double, " method dispatching" do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    @object.methods.should_not include(@method_name.to_s)
    @double = @space.create_double(@object, @method_name) {}
  end

  it "dispatches to Scenario that has an exact match" do
    scenario1_with_exact_match = Scenario.new(@double)
    scenario1_with_exact_match.with(:exact_match_1).returns {:return_1}
    scenario_with_no_match = Scenario.new(@double)
    scenario_with_no_match.with("nothing that matches").returns {:no_match}
    scenario2_with_exact_match = Scenario.new(@double)
    scenario2_with_exact_match.with(:exact_match_2).returns {:return_2}

    @object.foobar(:exact_match_1).should == :return_1
    @object.foobar(:exact_match_2).should == :return_2
  end

  it "dispatches to Scenario that has a wildcard match" do
    scenario2_with_wildcard_match = Scenario.new(@double)
    scenario2_with_wildcard_match.with_any_args.returns {:wild_card_value}
    scenario_with_no_match = Scenario.new(@double)
    scenario_with_no_match.with("nothing that matches").returns {:no_match}

    @object.foobar(:wildcard_match_1).should == :wild_card_value
    @object.foobar(:wildcard_match_2, 3).should == :wild_card_value
  end
end
end
