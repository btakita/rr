dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
describe Double, " method dispatching where there are no scenarios with duplicate ArgumentExpectations" do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    @object.methods.should_not include(@method_name.to_s)
    @double = @space.create_double(@object, @method_name)
  end

  it "dispatches to Scenario that has an exact match" do
    scenario1_with_exact_match = @space.create_scenario(@double)
    scenario1_with_exact_match.with(:exact_match_1).returns {:return_1}
    scenario_with_no_match = @space.create_scenario(@double)
    scenario_with_no_match.with("nothing that matches").returns {:no_match}
    scenario2_with_exact_match = @space.create_scenario(@double)
    scenario2_with_exact_match.with(:exact_match_2).returns {:return_2}

    @object.foobar(:exact_match_1).should == :return_1
    @object.foobar(:exact_match_2).should == :return_2
  end

  it "dispatches to Scenario that has a wildcard match" do
    scenario_with_wildcard_match = @space.create_scenario(@double)
    scenario_with_wildcard_match.with_any_args.returns {:wild_card_value}
    scenario_with_no_match = @space.create_scenario(@double)
    scenario_with_no_match.with("nothing that matches").returns {:no_match}

    @object.foobar(:wildcard_match_1).should == :wild_card_value
    @object.foobar(:wildcard_match_2, 3).should == :wild_card_value
  end
end

describe Double, " method dispatching where there are scenarios with duplicate ArgumentExpectations" do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    @object.methods.should_not include(@method_name.to_s)
    @double = @space.create_double(@object, @method_name)
  end

  it "dispatches to Scenario that has an exact match" do
    scenario1_with_exact_match = @space.create_scenario(@double)
    scenario1_with_exact_match.with(:exact_match).returns {:return_1}

    @object.foobar(:exact_match).should == :return_1

    scenario2_with_exact_match = @space.create_scenario(@double)
    scenario2_with_exact_match.with(:exact_match).returns {:return_2}

    @object.foobar(:exact_match).should == :return_2
  end

  it "dispatches to Scenario that has a wildcard match" do
    scenario_1 = @space.create_scenario(@double)
    scenario_1.with_any_args.returns {:return_1}

    @object.foobar(:anything).should == :return_1

    scenario_2 = @space.create_scenario(@double)
    scenario_2.with_any_args.returns {:return_2}

    @object.foobar(:anything).should == :return_2
  end
  
  it "raises ScenarioNotFoundError error when arguments do not match a scenario" do
    scenario_1 = @space.create_scenario(@double)
    scenario_1.with(1, 2)

    scenario_2 = @space.create_scenario(@double)
    scenario_2.with(3)

    proc {@object.foobar(:no_matching_args)}.should raise_error(
      ScenarioNotFoundError,
      "No scenario for arguments [:no_matching_args]"
    )
  end
end
end
