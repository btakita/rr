dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
describe Space, "#verify_doubles" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object1 = Object.new
    @object2 = Object.new
    @method_name = :foobar
  end

  it "verifies and deletes the doubles" do
    double1 = @space.create_double(@object1, @method_name)
    double1_verify_calls = 0
    double1_reset_calls = 0
    (class << double1; self; end).class_eval do
      define_method(:verify) do ||
        double1_verify_calls += 1
      end
      define_method(:reset) do ||
        double1_reset_calls += 1
      end
    end
    double2 = @space.create_double(@object2, @method_name)
    double2_verify_calls = 0
    double2_reset_calls = 0
    (class << double2; self; end).class_eval do
      define_method(:verify) do ||
        double2_verify_calls += 1
      end
      define_method(:reset) do ||
        double2_reset_calls += 1
      end
    end

    @space.verify_doubles
    double1_verify_calls.should == 1
    double2_verify_calls.should == 1
    double1_reset_calls.should == 1
    double1_reset_calls.should == 1
  end
end

describe Space, "#verify_double" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
  end

  it "verifies and deletes the double" do
    double = @space.create_double(@object, @method_name)
    @space.doubles[@object][@method_name].should === double
    @object.methods.should include("__rr__#{@method_name}__rr__")

    verify_calls = 0
    (class << double; self; end).class_eval do
      define_method(:verify) do ||
        verify_calls += 1
      end
    end
    @space.verify_double(@object, @method_name)
    verify_calls.should == 1

    @space.doubles[@object][@method_name].should be_nil
    @object.methods.should_not include("__rr__#{@method_name}__rr__")
  end

  it "deletes the double when verifying the double raises an error" do
    double = @space.create_double(@object, @method_name)
    @space.doubles[@object][@method_name].should === double
    @object.methods.should include("__rr__#{@method_name}__rr__")

    verify_called = true
    (class << double; self; end).class_eval do
      define_method(:verify) do ||
        verify_called = true
        raise "An Error"
      end
    end
    proc {@space.verify_double(@object, @method_name)}.should raise_error
    verify_called.should be_true

    @space.doubles[@object][@method_name].should be_nil
    @object.methods.should_not include("__rr__#{@method_name}__rr__")
  end
end

describe Space, "#verify_ordered_scenario", :shared => true do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    @double = @space.create_double(@object, @method_name)
  end
end

describe Space, "#verify_ordered_scenario where the passed in scenario is at the front of the queue" do
  it_should_behave_like "RR::Space#verify_ordered_scenario"

  it "keeps the scenario when times called is not verified" do
    scenario = @space.create_scenario(@double)
    @space.register_ordered_scenario(scenario)

    scenario.twice
    scenario.should_not be_times_called_verified

    @space.verify_ordered_scenario(scenario)
    @space.ordered_scenarios.should include(scenario)
  end
  
  it "removes the scenario when times called in verified" do
    scenario = @space.create_scenario(@double)
    @space.register_ordered_scenario(scenario)

    scenario.with(1).once
    @object.foobar(1)
    scenario.should be_times_called_verified

    @space.verify_ordered_scenario(scenario)
    @space.ordered_scenarios.should_not include(scenario)
  end
end

describe Space, "#verify_ordered_scenario where the passed in scenario is not at the front of the queue" do
  it_should_behave_like "RR::Space#verify_ordered_scenario"
  
  it "raises error" do
    first_scenario = @space.create_scenario(@double)
    @space.register_ordered_scenario(first_scenario)
    second_scenario = @space.create_scenario(@double)
    @space.register_ordered_scenario(second_scenario)

    proc do
      @space.verify_ordered_scenario(second_scenario)
    end.should raise_error(Errors::ScenarioOrderError)
  end
end
end