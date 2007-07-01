dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
describe Scenario, :shared => true do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    @double = @space.create_double(@object, @method_name)
    @scenario = @space.create_scenario(@double)
  end
end

describe Scenario, "#with" do
  it_should_behave_like "RR::Scenario"

  it "sets an ArgumentEqualityExpectation" do
    @scenario.with(1).should === @scenario
    @scenario.should be_exact_match(1)
    @scenario.should_not be_exact_match(2)
  end

  it "sets return value when block passed in" do
    @scenario.with(1) {:return_value}
    @object.foobar(1).should == :return_value
  end
end

describe Scenario, "#with_any_args" do
  it_should_behave_like "RR::Scenario"

  it "sets an ArgumentEqualityExpectation::Anything expectation" do
    @scenario.with_any_args.should === @scenario
    @scenario.should_not be_exact_match(1)
    @scenario.should be_wildcard_match(1)
  end

  it "sets return value when block passed in" do
    @scenario.with_any_args {:return_value}
    @object.foobar(:anything).should == :return_value
  end
end

describe Scenario, "#once" do
  it_should_behave_like "RR::Scenario"

  it "sets up a Times Called Expectation with 1" do
    @scenario.once.should === @scenario
    @scenario.call
    proc {@scenario.call}.should raise_error(Expectations::TimesCalledExpectationError)
  end

  it "sets return value when block passed in" do
    @scenario.with_any_args.once {:return_value}
    @object.foobar.should == :return_value
  end
end

describe Scenario, "#twice" do
  it_should_behave_like "RR::Scenario"

  it "sets up a Times Called Expectation with 2" do
    @scenario.twice.should === @scenario
    @scenario.call
    @scenario.call
    proc {@scenario.call}.should raise_error(Expectations::TimesCalledExpectationError)
  end

  it "sets return value when block passed in" do
    @scenario.with_any_args.twice {:return_value}
    @object.foobar.should == :return_value
  end
end

describe Scenario, "#times" do
  it_should_behave_like "RR::Scenario"

  it "sets up a Times Called Expectation with passed in times" do
    @scenario.times(3).should === @scenario
    @scenario.call
    @scenario.call
    @scenario.call
    proc {@scenario.call}.should raise_error(Expectations::TimesCalledExpectationError)
  end

  it "sets return value when block passed in" do
    @scenario.with_any_args.times(3) {:return_value}
    @object.foobar.should == :return_value
  end
end

describe Scenario, "#ordered" do
  it_should_behave_like "RR::Scenario"

  it "adds itself to the ordered scenarios list" do
    @scenario.ordered
    @space.ordered_scenarios.should include(@scenario)
  end

  it "does not double add itself" do
    @scenario.ordered
    @scenario.ordered
    @space.ordered_scenarios.should == [@scenario ]
  end

  it "sets ordered? to true" do
    @scenario.ordered
    @scenario.should be_ordered
  end
end

describe Scenario, "#ordered?" do
  it_should_behave_like "RR::Scenario"

  it "defaults to false" do
    @scenario.should_not be_ordered
  end
end

describe Scenario, "#returns" do
  it_should_behave_like "RR::Scenario"

  it "sets the value of the method" do
    @scenario.returns {:baz}.should === @scenario
    @scenario.call.should == :baz
  end
end

describe Scenario, "#call" do
  it_should_behave_like "RR::Scenario"
  
  it "calls the return proc when scheduled to call a proc" do
    @scenario.returns {|arg| "returning #{arg}"}
    @scenario.call(:foobar).should == "returning foobar"
  end

  it "returns nil when to returns is not set" do
    @scenario.call.should be_nil
  end

  it "works when times_called is not set" do
    @scenario.returns {:value}
    @scenario.call
  end

  it "verifes the times_called does not exceed the TimesCalledExpectation" do
    @scenario.times(2).returns {:value}

    @scenario.call(:foobar)
    @scenario.call(:foobar)
    proc {@scenario.call(:foobar)}.should raise_error(Expectations::TimesCalledExpectationError)
  end

  it "does not verify ordered if the Scenario is not ordered" do
    verify_ordered_scenario_called = false
    passed_in_scenario = nil
    (class << @space; self; end).class_eval do
      define_method :verify_ordered_scenario do |scenario|
        passed_in_scenario = scenario
        verify_ordered_scenario_called = true
      end
    end

    @scenario.returns {:value}.ordered
    @scenario.call(:foobar)
    verify_ordered_scenario_called.should be_true
    passed_in_scenario.should === @scenario
  end

  it "does not verify ordered if the Scenario is not ordered" do
    verify_ordered_scenario_called = false
    (class << @space; self; end).class_eval do
      define_method :verify_ordered_scenario do |scenario|
        verify_ordered_scenario_called = true
      end
    end

    @scenario.returns {:value}
    @scenario.call(:foobar)
    verify_ordered_scenario_called.should be_false
  end
end

describe Scenario, "#exact_match?" do
  it_should_behave_like "RR::Scenario"

  it "returns false when no expectation set" do
    @scenario.should_not be_exact_match()
    @scenario.should_not be_exact_match(nil)
    @scenario.should_not be_exact_match(Object.new)
    @scenario.should_not be_exact_match(1, 2, 3)
  end

  it "returns false when arguments are not an exact match" do
    @scenario.with(1, 2, 3)
    @scenario.should_not be_exact_match(1, 2)
    @scenario.should_not be_exact_match(1)
    @scenario.should_not be_exact_match()
    @scenario.should_not be_exact_match("does not match")
  end

  it "returns true when arguments are an exact match" do
    @scenario.with(1, 2, 3)
    @scenario.should be_exact_match(1, 2, 3)
  end
end

describe Scenario, "#wildcard_match?" do
  it_should_behave_like "RR::Scenario"

  it "returns false when no expectation set" do
    @scenario.should_not be_wildcard_match()
    @scenario.should_not be_wildcard_match(nil)
    @scenario.should_not be_wildcard_match(Object.new)
    @scenario.should_not be_wildcard_match(1, 2, 3)
  end

  it "returns true when arguments are an exact match" do
    @scenario.with(1, 2, 3)
    @scenario.should be_wildcard_match(1, 2, 3)
    @scenario.should_not be_wildcard_match(1, 2)
    @scenario.should_not be_wildcard_match(1)
    @scenario.should_not be_wildcard_match()
    @scenario.should_not be_wildcard_match("does not match")
  end

  it "returns true when with_any_args" do
    @scenario.with_any_args

    @scenario.should be_wildcard_match(1, 2, 3)
    @scenario.should be_wildcard_match(1, 2)
    @scenario.should be_wildcard_match(1)
    @scenario.should be_wildcard_match()
    @scenario.should be_wildcard_match("does not match")
  end
end

describe Scenario, "#times_called_verified?" do
  it_should_behave_like "RR::Scenario"

  it "returns false when times called does not match expectation" do
    @scenario.with(1, 2, 3).twice
    @object.foobar(1, 2, 3)
    @scenario.should_not be_times_called_verified
  end

  it "returns true when times called matches expectation" do
    @scenario.with(1, 2, 3).twice
    @object.foobar(1, 2, 3)
    @object.foobar(1, 2, 3)
    @scenario.should be_times_called_verified
  end

  it "returns false when there is no Times Called expectation" do
    @scenario.with(1, 2, 3)
    @scenario.times_called_expectation.should be_nil

    @scenario.should_not be_times_called_verified
    @object.foobar(1, 2, 3)
    @scenario.should_not be_times_called_verified
  end
end

describe Scenario, "#verify" do
  it_should_behave_like "RR::Scenario"

  it "verifies that times called expectation was met" do
    @scenario.twice.returns {:return_value}

    proc {@scenario.verify}.should raise_error(Expectations::TimesCalledExpectationError)
    @scenario.call
    proc {@scenario.verify}.should raise_error(Expectations::TimesCalledExpectationError)
    @scenario.call
    
    proc {@scenario.verify}.should_not raise_error
  end

  it "does not raise an error when there is no times called expectation" do
    proc {@scenario.verify}.should_not raise_error
    @scenario.call
    proc {@scenario.verify}.should_not raise_error
    @scenario.call
    proc {@scenario.verify}.should_not raise_error
  end
end
end
