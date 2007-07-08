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

  before do
    @scenario.with_any_args {:return_value}
  end

  it "returns self" do
    @scenario.with_no_args.should === @scenario
  end

  it "sets an AnyArgumentExpectation" do
    @scenario.should_not be_exact_match(1)
    @scenario.should be_wildcard_match(1)
  end

  it "sets return value when block passed in" do
    @object.foobar(:anything).should == :return_value
  end
end

describe Scenario, "#with_no_args" do
  it_should_behave_like "RR::Scenario"

  before do
    @scenario.with_no_args {:return_value}
  end

  it "returns self" do
    @scenario.with_no_args.should === @scenario
  end

  it "sets an ArgumentEqualityExpectation with no arguments" do
    @scenario.argument_expectation.should == Expectations::ArgumentEqualityExpectation.new()
  end

  it "sets return value when block passed in" do
    @object.foobar().should == :return_value
  end
end

describe Scenario, "#never" do
  it_should_behave_like "RR::Scenario"

  it "returns self" do
    @scenario.never.should === @scenario
  end

  it "sets up a Times Called Expectation with 0" do
    @scenario.never
    proc {@scenario.call}.should raise_error(Expectations::TimesCalledExpectationError)
  end

  it "sets return value when block passed in" do
    @scenario.with_any_args.never
    proc {@scenario.call}.should raise_error(Expectations::TimesCalledExpectationError)
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

  it "sets return value when block passed in" do
    @scenario.with_any_args.ordered {:return_value}
    @object.foobar.should == :return_value
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

describe Scenario, "#implemented_by" do
  it_should_behave_like "RR::Scenario"

  it "returns the scenario object" do
    @scenario.implemented_by(proc{:baz}).should === @scenario
  end

  it "sets the implementation to the passed in proc" do
    @scenario.implemented_by(proc{:baz})
    @scenario.call.should == :baz
  end

  it "sets the implementation to the passed in method" do
    def @object.foobar(a, b)
      [b, a]
    end
    @scenario.implemented_by(@object.method(:foobar))
    @scenario.call(1, 2).should == [2, 1]
  end
end

describe Scenario, "#call implemented by a proc" do
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

  it "raises ScenarioOrderError when ordered and called out of order" do
    scenario1 = @scenario
    scenario2 = @space.create_scenario(@double)

    scenario1.with(1).returns {:return_1}.ordered
    scenario2.with(2).returns {:return_2}.ordered

    proc do
      @object.foobar(2)
    end.should raise_error(Errors::ScenarioOrderError)
  end

  it "dispatches to Space#verify_ordered_scenario when ordered" do
    verify_ordered_scenario_called = false
    passed_in_scenario = nil
    @space.method(:verify_ordered_scenario).arity.should == 1
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

  it "does not dispatche to Space#verify_ordered_scenario when not ordered" do
    verify_ordered_scenario_called = false
    @space.method(:verify_ordered_scenario).arity.should == 1
    (class << @space; self; end).class_eval do
      define_method :verify_ordered_scenario do |scenario|
        verify_ordered_scenario_called = true
      end
    end

    @scenario.returns {:value}
    @scenario.call(:foobar)
    verify_ordered_scenario_called.should be_false
  end

  it "does not add block argument if no block passed in" do
    @scenario.with(1, 2).returns {|*args| args}

    args = @object.foobar(1, 2)
    args.should == [1, 2]
  end

  it "makes the block the last argument" do
    @scenario.with(1, 2).returns {|a, b, blk| blk}

    block = @object.foobar(1, 2) {|a, b| [b, a]}
    block.call(3, 4).should == [4, 3]
  end
end

describe Scenario, "#call implemented by a method" do
  it_should_behave_like "RR::Scenario"

  it "sends block to the method" do
    def @object.foobar(a, b)
      yield(a, b)
    end

    @scenario.with(1, 2).implemented_by(@object.method(:foobar))

    @object.foobar(1, 2) {|a, b| [b, a]}.should == [2, 1]
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
