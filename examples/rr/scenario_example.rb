require "examples/example_helper"

module RR
describe Scenario, :shared => true do
  before do
    @space = Space.new
    @object = Object.new
    def @object.foobar(a, b)
      [b, a]
    end
    @double = @space.double(@object, :foobar)
    @scenario = @space.scenario(@double)
  end
end

describe Scenario, "#with" do
  it_should_behave_like "RR::Scenario"

  it "returns ScenarioDefinition" do
    @scenario.with(1).should === @scenario.definition
  end

  it "sets an ArgumentEqualityExpectation" do
    @scenario.with(1)
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

  it "returns ScenarioDefinition" do
    @scenario.with_no_args.should === @scenario.definition
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

  it "returns ScenarioDefinition" do
    @scenario.with_no_args.should === @scenario.definition
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

  it "returns ScenarioDefinition" do
    @scenario.never.should === @scenario.definition
  end

  it "sets up a Times Called Expectation with 0" do
    @scenario.never
    proc {@scenario.call(@double)}.should raise_error(Errors::TimesCalledError)
  end

  it "sets return value when block passed in" do
    @scenario.with_any_args.never
    proc {@scenario.call(@double)}.should raise_error(Errors::TimesCalledError)
  end
end

describe Scenario, "#once" do
  it_should_behave_like "RR::Scenario"

  it "returns ScenarioDefinition" do
    @scenario.once.should === @scenario.definition
  end

  it "sets up a Times Called Expectation with 1" do
    @scenario.once
    @scenario.call(@double)
    proc {@scenario.call(@double)}.should raise_error(Errors::TimesCalledError)
  end

  it "sets return value when block passed in" do
    @scenario.with_any_args.once {:return_value}
    @object.foobar.should == :return_value
  end
end

describe Scenario, "#twice" do
  it_should_behave_like "RR::Scenario"

  it "returns ScenarioDefinition" do
    @scenario.twice.should === @scenario.definition
  end

  it "sets up a Times Called Expectation with 2" do
    @scenario.twice
    @scenario.call(@double)
    @scenario.call(@double)
    proc {@scenario.call(@double)}.should raise_error(Errors::TimesCalledError)
  end

  it "sets return value when block passed in" do
    @scenario.with_any_args.twice {:return_value}
    @object.foobar.should == :return_value
  end
end

describe Scenario, "#at_least" do
  it_should_behave_like "RR::Scenario"

  it "returns ScenarioDefinition" do
    @scenario.with_any_args.at_least(2).should === @scenario.definition
  end

  it "sets up a Times Called Expectation with 1" do
    @scenario.at_least(2)
    @scenario.definition.times_matcher.should == TimesCalledMatchers::AtLeastMatcher.new(2)
  end

  it "sets return value when block passed in" do
    @scenario.with_any_args.at_least(2) {:return_value}
    @object.foobar.should == :return_value
  end
end

describe Scenario, "#at_most" do
  it_should_behave_like "RR::Scenario"

  it "returns ScenarioDefinition" do
    @scenario.with_any_args.at_most(2).should === @scenario.definition
  end

  it "sets up a Times Called Expectation with 1" do
    @scenario.at_most(2)
    @scenario.call(@double)
    @scenario.call(@double)
    proc do
      @scenario.call(@double)
    end.should raise_error(
      Errors::TimesCalledError,
      "Called 3 times.\nExpected at most 2 times."
    )
  end

  it "sets return value when block passed in" do
    @scenario.with_any_args.at_most(2) {:return_value}
    @object.foobar.should == :return_value
  end
end

describe Scenario, "#times" do
  it_should_behave_like "RR::Scenario"

  it "returns ScenarioDefinition" do
    @scenario.times(3).should === @scenario.definition
  end

  it "sets up a Times Called Expectation with passed in times" do
    @scenario.times(3)
    @scenario.call(@double)
    @scenario.call(@double)
    @scenario.call(@double)
    proc {@scenario.call(@double)}.should raise_error(Errors::TimesCalledError)
  end

  it "sets return value when block passed in" do
    @scenario.with_any_args.times(3) {:return_value}
    @object.foobar.should == :return_value
  end
end

describe Scenario, "#any_number_of_times" do
  it_should_behave_like "RR::Scenario"

  it "returns ScenarioDefinition" do
    @scenario.any_number_of_times.should === @scenario.definition
  end

  it "sets up a Times Called Expectation with AnyTimes matcher" do
    @scenario.any_number_of_times
    @scenario.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
  end

  it "sets return value when block passed in" do
    @scenario.with_any_args.any_number_of_times {:return_value}
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
    @scenario.with_any_args.once.ordered {:return_value}
    @object.foobar.should == :return_value
  end
end

describe Scenario, "#ordered?" do
  it_should_behave_like "RR::Scenario"

  it "defaults to false" do
    @scenario.should_not be_ordered
  end
end

describe Scenario, "#yields" do
  it_should_behave_like "RR::Scenario"

  it "returns ScenarioDefinition" do
    @scenario.yields(:baz).should === @scenario.definition
  end

  it "yields the passed in argument to the call block when there is no returns value set" do
    @scenario.with_any_args.yields(:baz)
    passed_in_block_arg = nil
    @object.foobar {|arg| passed_in_block_arg = arg}.should == nil
    passed_in_block_arg.should == :baz
  end

  it "yields the passed in argument to the call block when there is a no returns value set" do
    @scenario.with_any_args.yields(:baz).returns(:return_value)

    passed_in_block_arg = nil
    @object.foobar {|arg| passed_in_block_arg = arg}.should == :return_value
    passed_in_block_arg.should == :baz
  end

  it "sets return value when block passed in" do
    @scenario.with_any_args.yields {:return_value}
    @object.foobar {}.should == :return_value
  end
end

describe Scenario, "#after_call" do
  it_should_behave_like "RR::Scenario"

  it "returns ScenarioDefinition" do
    @scenario.after_call {}.should === @scenario.definition
  end

  it "sends return value of Scenario implementation to after_call" do
    return_value = {}
    @scenario.returns(return_value).after_call do |value|
      value[:foo] = :bar
      value
    end

    actual_value = @scenario.call(@double)
    actual_value.should === return_value
    actual_value.should == {:foo => :bar}
  end

  it "receives the return value in the after_call callback" do
    return_value = :returns_value
    @scenario.returns(return_value).after_call do |value|
      :after_call_value
    end

    actual_value = @scenario.call(@double)
    actual_value.should == :after_call_value
  end

  it "allows after_call to mock the return value" do
    return_value = Object.new
    @scenario.with_any_args.returns(return_value).after_call do |value|
      mock(value).inner_method(1) {:baz}
      value
    end

    @object.foobar.inner_method(1).should == :baz
  end

  it "raises an error when not passed a block" do
    proc do
      @scenario.after_call
    end.should raise_error(ArgumentError, "after_call expects a block")
  end
end

describe Scenario, "#returns" do
  it_should_behave_like "RR::Scenario"

  it "returns ScenarioDefinition" do
    @scenario.returns {:baz}.should === @scenario.definition
    @scenario.returns(:baz).should === @scenario.definition
  end

  it "sets the value of the method when passed a block" do
    @scenario.returns {:baz}
    @scenario.call(@double).should == :baz
  end

  it "sets the value of the method when passed an argument" do
    @scenario.returns(:baz)
    @scenario.call(@double).should == :baz
  end

  it "returns false when passed false" do
    @scenario.returns(false)
    @scenario.call(@double).should == false
  end

  it "raises an error when both argument and block is passed in" do
    proc do
      @scenario.returns(:baz) {:another}
    end.should raise_error(ArgumentError, "returns cannot accept both an argument and a block")
  end
end

describe Scenario, "#implemented_by" do
  it_should_behave_like "RR::Scenario"

  it "returns the ScenarioDefinition" do
    @scenario.implemented_by(proc{:baz}).should === @scenario.definition
  end

  it "sets the implementation to the passed in proc" do
    @scenario.implemented_by(proc{:baz})
    @scenario.call(@double).should == :baz
  end

  it "sets the implementation to the passed in method" do
    def @object.foobar(a, b)
      [b, a]
    end
    @scenario.implemented_by(@object.method(:foobar))
    @scenario.call(@double, 1, 2).should == [2, 1]
  end
end

describe Scenario, "#implemented_by_original_method" do
  it_should_behave_like "RR::Scenario"

  it "returns the ScenarioDefinition object" do
    @scenario.implemented_by_original_method.should === @scenario.definition
  end

  it "sets the implementation to the original method" do
    @scenario.implemented_by_original_method
    @scenario.call(@double, 1, 2).should == [2, 1]
  end

  it "calls method_missing when original_method does not exist" do
    class << @object
      def method_missing(method_name, *args, &block)
        "method_missing for #{method_name}(#{args.inspect})"
      end
    end
    double = @space.double(@object, :does_not_exist)
    scenario = @space.scenario(double)
    scenario.with_any_args
    scenario.implemented_by_original_method

    return_value = @object.does_not_exist(1, 2)
    return_value.should == "method_missing for does_not_exist([1, 2])"
  end
end

describe Scenario, "#call implemented by a proc" do
  it_should_behave_like "RR::Scenario"
  
  it "calls the return proc when implemented by a proc" do
    @scenario.returns {|arg| "returning #{arg}"}
    @scenario.call(@double, :foobar).should == "returning foobar"
  end

  it "calls and returns the after_call when after_call is set" do
    @scenario.returns {|arg| "returning #{arg}"}.after_call do |value|
      "#{value} after call"
    end
    @scenario.call(@double, :foobar).should == "returning foobar after call"
  end

  it "returns nil when to returns is not set" do
    @scenario.call(@double).should be_nil
  end

  it "works when times_called is not set" do
    @scenario.returns {:value}
    @scenario.call(@double)
  end

  it "verifes the times_called does not exceed the TimesCalledExpectation" do
    @scenario.times(2).returns {:value}

    @scenario.call(@double, :foobar)
    @scenario.call(@double, :foobar)
    proc {@scenario.call(@double, :foobar)}.should raise_error(Errors::TimesCalledError)
  end

  it "raises ScenarioOrderError when ordered and called out of order" do
    scenario1 = @scenario
    scenario2 = @space.scenario(@double)

    scenario1.with(1).returns {:return_1}.ordered.once
    scenario2.with(2).returns {:return_2}.ordered.once

    proc do
      @object.foobar(2)
    end.should raise_error(
      Errors::ScenarioOrderError,
      "foobar(2) called out of order in list\n" <<
      "- foobar(1)\n" <<
      "- foobar(2)"
    )
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
    @scenario.call(@double, :foobar)
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
    @scenario.call(@double, :foobar)
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

  it "raises ArgumentError when yields was called and no block passed in" do
    @scenario.with(1, 2).yields(55)

    proc do
      @object.foobar(1, 2)
    end.should raise_error(ArgumentError, "A Block must be passed into the method call when using yields")
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

describe Scenario, "#attempt?" do
  it_should_behave_like "RR::Scenario"

  it "returns true when TimesCalledExpectation#attempt? is true" do
    @scenario.with(1, 2, 3).twice
    @scenario.call(@double, 1, 2, 3)
    @scenario.times_called_expectation.should be_attempt
    @scenario.should be_attempt
  end

  it "returns false when TimesCalledExpectation#attempt? is true" do
    @scenario.with(1, 2, 3).twice
    @scenario.call(@double, 1, 2, 3)
    @scenario.call(@double, 1, 2, 3)
    @scenario.times_called_expectation.should_not be_attempt
    @scenario.should_not be_attempt
  end

  it "returns true when there is no Times Called expectation" do
    @scenario.with(1, 2, 3)
    @scenario.definition.times_called_matcher.should be_nil
    @scenario.should be_attempt
  end
end

describe Scenario, "#verify" do
  it_should_behave_like "RR::Scenario"

  it "verifies that times called expectation was met" do
    @scenario.twice.returns {:return_value}

    proc {@scenario.verify}.should raise_error(Errors::TimesCalledError)
    @scenario.call(@double)
    proc {@scenario.verify}.should raise_error(Errors::TimesCalledError)
    @scenario.call(@double)
    
    proc {@scenario.verify}.should_not raise_error
  end

  it "does not raise an error when there is no times called expectation" do
    proc {@scenario.verify}.should_not raise_error
    @scenario.call(@double)
    proc {@scenario.verify}.should_not raise_error
    @scenario.call(@double)
    proc {@scenario.verify}.should_not raise_error
  end
end

describe Scenario, "#terminal?" do
  it_should_behave_like "RR::Scenario"

  it "returns true when times_called_expectation's terminal? is true" do
    @scenario.once
    @scenario.times_called_expectation.should be_terminal
    @scenario.should be_terminal
  end

  it "returns false when times_called_expectation's terminal? is false" do
    @scenario.any_number_of_times
    @scenario.times_called_expectation.should_not be_terminal
    @scenario.should_not be_terminal
  end

  it "returns false when there is no times_called_matcher" do
    @scenario.definition.times_called_matcher.should be_nil
    @scenario.should_not be_terminal
  end
end

describe Scenario, "#method_name" do
  it_should_behave_like "RR::Scenario"

  it "returns the Double's method_name" do
    @double.method_name.should == :foobar
    @scenario.method_name.should == :foobar
  end
end

describe Scenario, "#expected_arguments" do
  it_should_behave_like "RR::Scenario"

  it "returns argument expectation's expected_arguments when there is a argument expectation" do
    @scenario.with(1, 2)
    @scenario.expected_arguments.should == [1, 2]
  end

  it "returns an empty array when there is no argument expectation" do
    @scenario.argument_expectation.should be_nil
    @scenario.expected_arguments.should == []
  end
end
end