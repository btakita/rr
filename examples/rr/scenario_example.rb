dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
describe Scenario, :shared => true do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    @double = @space.create_double(@object, @method_name) {}
    @scenario = Scenario.new(@double)
  end
end

describe Scenario, ".new" do
  it_should_behave_like "RR::Scenario"
  
  it "registers self to double" do
    @double.scenarios.should include(@scenario)
  end
end

describe Scenario, "#with" do
  it_should_behave_like "RR::Scenario"

  it "sets an ArgumentEqualityExpectation" do
    @scenario.with(1).should === @scenario
    @object.foobar(1)
    proc {@object.foobar(2)}.should raise_error(Expectations::ArgumentEqualityExpectationError)
  end
end

describe Scenario, "#once" do
  it_should_behave_like "RR::Scenario"

  it "sets up a Times Called Expectation with 1" do
    @scenario.once.should === @scenario
    @object.foobar
    proc {@object.foobar}.should raise_error(Expectations::TimesCalledExpectationError)
  end
end

describe Scenario, "#twice" do
  it_should_behave_like "RR::Scenario"

  it "sets up a Times Called Expectation with 2" do
    @scenario.twice.should === @scenario
    @object.foobar
    @object.foobar
    proc {@object.foobar}.should raise_error(Expectations::TimesCalledExpectationError)
  end
end

describe Scenario, "#times" do
  it_should_behave_like "RR::Scenario"

  it "sets up a Times Called Expectation with passed in times" do
    @scenario.times(3).should === @scenario
    @object.foobar
    @object.foobar
    @object.foobar
    proc {@object.foobar}.should raise_error(Expectations::TimesCalledExpectationError)
  end
end

describe Scenario, "#returns" do
  it_should_behave_like "RR::Scenario"

  it "sets the value of the method" do
    @scenario.returns {:baz}.should === @scenario
    @object.foobar.should == :baz
  end
end

describe Scenario, "#original_method" do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
  end

  it "returns the original method of the object when one exists" do
    def @object.foobar
      :original_foobar
    end
    @double = @space.create_double(@object, @method_name) {}
    @scenario = Scenario.new(@double)

    @scenario.original_method.call.should == :original_foobar
  end
end

describe Scenario, "#call" do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    @scenario = @space.create_scenario(@object, @method_name)
  end

  it "calls the return proc when scheduled to call a proc" do
    @scenario.returns {|arg| "returning #{arg}"}
    @scenario.call(:foobar).should == "returning foobar"
  end

  it "increments times called" do
    @scenario.returns {:value}

    @scenario.times_called.should == 0
    @scenario.call(:foobar)
    @scenario.times_called.should == 1
    @scenario.call(:foobar)
    @scenario.times_called.should == 2
  end
end

describe Scenario, "#exact_match?" do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    @scenario = @space.create_scenario(@object, @method_name)
  end

  it "returns true when arguments are an exact match" do
    @scenario.with(1, 2, 3)
    @scenario.should be_exact_match(1, 2, 3)
    @scenario.should_not be_exact_match(1, 2)
    @scenario.should_not be_exact_match(1)
    @scenario.should_not be_exact_match()
    @scenario.should_not be_exact_match("does not match")
  end
end

describe Scenario, "#wildcard_match?" do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    @scenario = @space.create_scenario(@object, @method_name)
  end

  it "returns true when arguments are an exact match" do
    @scenario.with(Expectations::ArgumentEqualityExpectation::Anything.new)
    @scenario.should be_wildcard_match(1, 2, 3)
    @scenario.should be_wildcard_match(1, 2)
    @scenario.should be_wildcard_match(1)
    @scenario.should be_wildcard_match()
    @scenario.should be_wildcard_match("does not match")
  end
end

describe Scenario, "#verify" do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    @scenario = @space.create_scenario(@object, @method_name)
  end

  it "verifies that times called condition was met" do
    @scenario.twice.returns {:return_value}

    proc {@scenario.verify}.should raise_error(Expectations::TimesCalledExpectationError)
    @scenario.call
    proc {@scenario.verify}.should raise_error(Expectations::TimesCalledExpectationError)
    @scenario.call
    
    proc {@scenario.verify}.should_not raise_error
  end
end
end
