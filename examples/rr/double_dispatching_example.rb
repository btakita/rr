dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
describe Double, "method dispatching", :shared => true do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    @object.methods.should_not include(@method_name.to_s)
    @double = @space.create_double(@object, @method_name)
  end
end

describe Double, " method dispatching where method name has a ! in it" do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar!
    @object.methods.should_not include(@method_name.to_s)
    @double = @space.create_double(@object, @method_name)
  end

  it "executes the block" do
    scenario = @space.create_scenario(@double)
    scenario.with(1, 2) {:return_value}
    @object.foobar!(1, 2).should == :return_value
  end
end

describe Double, " method dispatching where method name has a ? in it" do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar?
    @object.methods.should_not include(@method_name.to_s)
    @double = @space.create_double(@object, @method_name)
  end

  it "executes the block" do
    scenario = @space.create_scenario(@double)
    scenario.with(1, 2) {:return_value}
    @object.foobar?(1, 2).should == :return_value
  end
end

describe Double, " method dispatching where the scenario takes a block" do
  it_should_behave_like "RR::Double method dispatching"

  it "executes the block" do
    method_fixture = Object.new
     class << method_fixture
      def method_with_block(a, b)
        yield(a,b)
      end
    end
    scenario = @space.create_scenario(@double)
    scenario.with(1, 2).implemented_by(method_fixture.method(:method_with_block))
    @object.foobar(1, 2) {|a, b| [b, a]}.should == [2, 1]
  end
end

describe Double, " method dispatching where there are no scenarios with duplicate ArgumentExpectations" do
  it_should_behave_like "RR::Double method dispatching"

  it "dispatches to Scenario that have an exact match" do
    scenario1_with_exact_match = @space.create_scenario(@double)
    scenario1_with_exact_match.with(:exact_match_1).returns {:return_1}
    scenario_with_no_match = @space.create_scenario(@double)
    scenario_with_no_match.with("nothing that matches").returns {:no_match}
    scenario2_with_exact_match = @space.create_scenario(@double)
    scenario2_with_exact_match.with(:exact_match_2).returns {:return_2}

    @object.foobar(:exact_match_1).should == :return_1
    @object.foobar(:exact_match_2).should == :return_2
  end

  it "dispatches to Scenario that have a wildcard match" do
    scenario_with_wildcard_match = @space.create_scenario(@double)
    scenario_with_wildcard_match.with_any_args.returns {:wild_card_value}
    scenario_with_no_match = @space.create_scenario(@double)
    scenario_with_no_match.with("nothing that matches").returns {:no_match}

    @object.foobar(:wildcard_match_1).should == :wild_card_value
    @object.foobar(:wildcard_match_2, 3).should == :wild_card_value
  end
end

describe Double, " method dispatching where there are scenarios" do
  it_should_behave_like "RR::Double method dispatching"

  it "raises ScenarioNotFoundError error when arguments do not match a scenario" do
    scenario_1 = @space.create_scenario(@double)
    scenario_1.with(1, 2)

    scenario_2 = @space.create_scenario(@double)
    scenario_2.with(3)

    proc {@object.foobar(:no_matching_args)}.should raise_error(
      Errors::ScenarioNotFoundError,
      "No scenario for arguments [:no_matching_args]"
    )
  end
end

describe Double, " method dispatching where there are scenarios with duplicate Exact Match ArgumentExpectations" do
  it_should_behave_like "RR::Double method dispatching"

  it "dispatches to Scenario that have an exact match" do
    scenario1_with_exact_match = @space.create_scenario(@double)
    scenario1_with_exact_match.with(:exact_match).returns {:return_1}

    @object.foobar(:exact_match).should == :return_1
  end

  it "dispatches to the first Scenario that have an exact match" do
    scenario1_with_exact_match = @space.create_scenario(@double)
    scenario1_with_exact_match.with(:exact_match).returns {:return_1}

    scenario2_with_exact_match = @space.create_scenario(@double)
    scenario2_with_exact_match.with(:exact_match).returns {:return_2}

    @object.foobar(:exact_match).should == :return_1
  end

  it "dispatches the second Scenario with an exact match
      when the first scenario's Times Called expectation is satisfied" do
    scenario1_with_exact_match = @space.create_scenario(@double)
    scenario1_with_exact_match.with(:exact_match).returns {:return_1}.once

    scenario2_with_exact_match = @space.create_scenario(@double)
    scenario2_with_exact_match.with(:exact_match).returns {:return_2}.once

    @object.foobar(:exact_match)
    @object.foobar(:exact_match).should == :return_2
  end

  it "raises TimesCalledError when all of the scenarios Times Called expectation is satisfied" do
    scenario1_with_exact_match = @space.create_scenario(@double)
    scenario1_with_exact_match.with(:exact_match).returns {:return_1}.once

    scenario2_with_exact_match = @space.create_scenario(@double)
    scenario2_with_exact_match.with(:exact_match).returns {:return_2}.once

    @object.foobar(:exact_match)
    @object.foobar(:exact_match)
    proc do
      @object.foobar(:exact_match)
    end.should raise_error(Errors::TimesCalledError)
  end
end

describe Double, " method dispatching where there are scenarios with duplicate Wildcard Match ArgumentExpectations" do
  it_should_behave_like "RR::Double method dispatching"

  it "dispatches to Scenario that have a wildcard match" do
    scenario_1 = @space.create_scenario(@double)
    scenario_1.with_any_args.returns {:return_1}

    @object.foobar(:anything).should == :return_1
  end

  it "dispatches to the first Scenario that has a wildcard match" do
    scenario_1 = @space.create_scenario(@double)
    scenario_1.with_any_args.returns {:return_1}

    scenario_2 = @space.create_scenario(@double)
    scenario_2.with_any_args.returns {:return_2}

    @object.foobar(:anything).should == :return_1
  end

  it "dispatches the second Scenario with a wildcard match
      when the first scenario's Times Called expectation is satisfied" do
    scenario_1 = @space.create_scenario(@double)
    scenario_1.with_any_args.returns {:return_1}.once

    scenario_2 = @space.create_scenario(@double)
    scenario_2.with_any_args.returns {:return_2}.once

    @object.foobar(:anything)
    @object.foobar(:anything).should == :return_2
  end

  it "raises TimesCalledError when all of the scenarios Times Called expectation is satisfied" do
    scenario_1 = @space.create_scenario(@double)
    scenario_1.with_any_args.returns {:return_1}.once

    scenario_2 = @space.create_scenario(@double)
    scenario_2.with_any_args.returns {:return_2}.once

    @object.foobar(:anything)
    @object.foobar(:anything)
    proc do
      @object.foobar(:anything)
    end.should raise_error(Errors::TimesCalledError)
  end
end
end
