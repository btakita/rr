require "spec/example_helper"

module RR
describe ScenarioCreator, :shared => true do
  before(:each) do
    @space = Space.new
    @subject = Object.new
    @creator = ScenarioCreator.new(@space)
  end
end

describe ScenarioCreator, " strategy definition", :shared => true do
  it_should_behave_like "RR::ScenarioCreator"

  it "returns self when passing no args" do
    @creator.__send__(@method_name).should === @creator
  end

  it "returns a ScenarioMethodProxy when passed a subject" do
    scenario = @creator.__send__(@method_name, @subject).foobar
    scenario.should be_instance_of(ScenarioDefinition)
  end

  it "returns a ScenarioMethodProxy when passed Kernel" do
    scenario = @creator.__send__(@method_name, Kernel).foobar
    scenario.should be_instance_of(ScenarioDefinition)
  end

  it "raises error if passed a method name and a block" do
    proc do
      @creator.__send__(@method_name, @subject, :foobar) {}
    end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
  end

  it "raises error when using mock strategy" do
    @creator.mock
    proc do
      @creator.__send__(@method_name)
    end.should raise_error(
      Errors::ScenarioDefinitionError,
      "This Scenario already has a mock strategy"
    )
  end

  it "raises error when using stub strategy" do
    @creator.stub
    proc do
      @creator.__send__(@method_name)
    end.should raise_error(
      Errors::ScenarioDefinitionError,
      "This Scenario already has a stub strategy"
    )
  end

  it "raises error when using do_not_call strategy" do
    @creator.do_not_call
    proc do
      @creator.__send__(@method_name)
    end.should raise_error(
      Errors::ScenarioDefinitionError,
      "This Scenario already has a do_not_call strategy"
    )
  end
end

describe ScenarioCreator, "#mock" do
  it_should_behave_like "RR::ScenarioCreator strategy definition"

  before do
    @method_name = :mock
  end

  it "sets up the RR mock call chain" do
    creates_mock_call_chain(@creator.mock(@subject))
  end

  it "creates a mock Scenario for method when passed a second argument with rr_mock" do
    creates_scenario_with_method_name(
      @creator.mock(@subject, :foobar)
    )
  end

  it "sets up the ScenarioDefinition to be in returns block_callback_strategy" do
    scenario = @creator.mock(@subject, :foobar)
    scenario.block_callback_strategy.should == :returns
  end

  def creates_scenario_with_method_name(scenario)
    scenario.with(1, 2) {:baz}
    scenario.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
    scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
    scenario.argument_expectation.expected_arguments.should == [1, 2]

    @subject.foobar(1, 2).should == :baz
  end

  def creates_mock_call_chain(creator)
    scenario = creator.foobar(1, 2) {:baz}
    scenario.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
    scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
    scenario.argument_expectation.expected_arguments.should == [1, 2]

    @subject.foobar(1, 2).should == :baz
  end
end

describe ScenarioCreator, "#stub" do
  it_should_behave_like "RR::ScenarioCreator strategy definition"

  before do
    @method_name = :stub
  end

  it "sets up the RR stub call chain" do
    creates_stub_call_chain(@creator.stub(@subject))
  end

  it "creates a stub Scenario for method when passed a second argument" do
    creates_scenario_with_method_name(@creator.stub(@subject, :foobar))
  end

  it "sets up the ScenarioDefinition to be in returns block_callback_strategy" do
    scenario = @creator.stub(@subject, :foobar)
    scenario.block_callback_strategy.should == :returns
  end

  def creates_scenario_with_method_name(scenario)
    scenario.with(1, 2) {:baz}
    scenario.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
    scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
    @subject.foobar(1, 2).should == :baz
  end

  def creates_stub_call_chain(creator)
    scenario = creator.foobar(1, 2) {:baz}
    scenario.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
    scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
    @subject.foobar(1, 2).should == :baz
  end
end

describe ScenarioCreator, "#do_not_call" do
  it_should_behave_like "RR::ScenarioCreator strategy definition"

  before do
    @method_name = :do_not_call
  end

  it "raises error when probed" do
    @creator.probe
    proc do
      @creator.do_not_call
    end.should raise_error(
      Errors::ScenarioDefinitionError,
      "Scenarios cannot be probed when using do_not_call strategy"
    )
  end

  it "sets up the RR do_not_call call chain" do
    creates_do_not_call_call_chain(@creator.do_not_call(@subject))
  end

  it "sets up the RR do_not_call call chain" do
    creates_do_not_call_call_chain(@creator.dont_call(@subject))
  end

  it "sets up the RR do_not_call call chain" do
    creates_do_not_call_call_chain(@creator.do_not_allow(@subject))
  end

  it "sets up the RR do_not_call call chain" do
    creates_do_not_call_call_chain(@creator.dont_allow(@subject))
  end

  it "creates a mock Scenario for method when passed a second argument" do
    creates_scenario_with_method_name(@creator.do_not_call(@subject, :foobar))
  end

  it "creates a mock Scenario for method when passed a second argument" do
    creates_scenario_with_method_name(@creator.dont_call(@subject, :foobar))
  end

  it "creates a mock Scenario for method when passed a second argument" do
    creates_scenario_with_method_name(@creator.do_not_allow(@subject, :foobar))
  end

  it "creates a mock Scenario for method when passed a second argument" do
    creates_scenario_with_method_name(@creator.dont_allow(@subject, :foobar))
  end

  def creates_scenario_with_method_name(scenario)
    scenario.with(1, 2)
    scenario.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(0)
    scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
    scenario.argument_expectation.expected_arguments.should == [1, 2]

    proc do
      @subject.foobar(1, 2)
    end.should raise_error(Errors::TimesCalledError)
    reset
    nil
  end

  def creates_do_not_call_call_chain(creator)
    scenario = creator.foobar(1, 2)
    scenario.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(0)
    scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
    scenario.argument_expectation.expected_arguments.should == [1, 2]

    proc do
      @subject.foobar(1, 2)
    end.should raise_error(Errors::TimesCalledError)
    reset
    nil
  end
end

describe ScenarioCreator, "(#probe or #proxy) and #stub" do
  it_should_behave_like "RR::ScenarioCreator"

  before do
    class << @subject
      def foobar(*args)
        :original_foobar
      end
    end
  end

  it "raises error when using do_not_call strategy" do
    @creator.do_not_call
    proc do
      @creator.probe
    end.should raise_error(
      Errors::ScenarioDefinitionError,
      "Scenarios cannot be probed when using do_not_call strategy"
    )
  end

  it "sets up the RR probe call chain" do
    scenario = @creator.stub.probe(@subject).foobar(1, 2) {:baz}
    scenario.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
    scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
    @subject.foobar(1, 2).should == :baz
  end

  it "sets up the RR proxy call chain" do
    scenario = @creator.stub.proxy(@subject).foobar(1, 2) {:baz}
    scenario.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
    scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
    @subject.foobar(1, 2).should == :baz
  end

  it "creates a probe Scenario for method when passed a second argument" do
    scenario = @creator.stub.probe(@subject, :foobar)
    scenario.with(1, 2) {:baz}
    scenario.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
    scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
    @subject.foobar(1, 2).should == :baz
  end

  it "creates a proxy Scenario for method when passed a second argument" do
    scenario = @creator.stub.proxy(@subject, :foobar)
    scenario.with(1, 2) {:baz}
    scenario.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
    scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
    @subject.foobar(1, 2).should == :baz
  end
  
  it "sets up the ScenarioDefinition to be in after_call block_callback_strategy" do
    def @subject.foobar
      :original_implementation_value
    end

    args = nil
    scenario = @creator.stub.proxy(@subject, :foobar).with() do |*args|
      args = args
    end
    @subject.foobar
    args.should == [:original_implementation_value]
    scenario.block_callback_strategy.should == :after_call
  end
end

describe ScenarioCreator, "#instance_of" do
  it_should_behave_like "RR::ScenarioCreator"

  it "raises an error when not passed a class" do
    proc do
      @creator.instance_of(Object.new)
    end.should raise_error(ArgumentError, "instance_of only accepts class objects")
  end

  it "sets up the RR probe call chain" do
    klass = Class.new
    scenario = @creator.stub.instance_of(klass).foobar(1, 2) {:baz}
    scenario.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
    scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
    klass.new.foobar(1, 2).should == :baz
  end

  it "creates a probe Scenario for method when passed a second argument" do
    klass = Class.new
    scenario = @creator.stub.instance_of(klass, :foobar)
    scenario.with(1, 2) {:baz}
    scenario.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
    scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
    klass.new.foobar(1, 2).should == :baz
  end
end

describe ScenarioCreator, "#create! using no strategy" do
  it_should_behave_like "RR::ScenarioCreator"

  it "raises error" do
    proc do
      @creator.create!(@subject, :foobar, 1, 2)
    end.should raise_error(
      Errors::ScenarioDefinitionError,
      "This Scenario has no strategy"
    )
  end
end

describe ScenarioCreator, "#create! using mock strategy" do
  it_should_behave_like "RR::ScenarioCreator"
  
  before do
    @creator.mock
  end

  it "sets expectations on the subject" do
    @creator.create!(@subject, :foobar, 1, 2) {:baz}.twice

    @subject.foobar(1, 2).should == :baz
    @subject.foobar(1, 2).should == :baz
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
  end
end

describe ScenarioCreator, "#create! using stub strategy" do
  it_should_behave_like "RR::ScenarioCreator"

  before do
    @creator.stub
  end

  it "stubs the subject without any args" do
    @creator.create!(@subject, :foobar) {:baz}
    @subject.foobar.should == :baz
  end

  it "stubs the subject mapping passed in args with the output" do
    @creator.create!(@subject, :foobar, 1, 2) {:one_two}
    @creator.create!(@subject, :foobar, 1) {:one}
    @creator.create!(@subject, :foobar) {:nothing}
    @subject.foobar.should == :nothing
    @subject.foobar(1).should == :one
    @subject.foobar(1, 2).should == :one_two
  end
end

describe ScenarioCreator, "#create! using do_not_call strategy" do
  it_should_behave_like "RR::ScenarioCreator"

  before do
    @creator.do_not_call
  end

  it "sets expectation for method to never be called with any arguments when on arguments passed in" do
    @creator.create!(@subject, :foobar)
    proc {@subject.foobar}.should raise_error(Errors::TimesCalledError)
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
  end

  it "sets expectation for method to never be called with passed in arguments" do
    @creator.create!(@subject, :foobar, 1, 2)
    proc {@subject.foobar}.should raise_error(Errors::ScenarioNotFoundError)
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
  end

  it "sets expectation for method to never be called with no arguments when with_no_args is set" do
    @creator.create!(@subject, :foobar).with_no_args
    proc {@subject.foobar}.should raise_error(Errors::TimesCalledError)
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::ScenarioNotFoundError)
  end
end

describe ScenarioCreator, "#create! using mock strategy with probe" do
  it_should_behave_like "RR::ScenarioCreator"

  before do
    @creator.mock
    @creator.probe
  end

  it "sets expectations on the subject while calling the original method" do
    def @subject.foobar(*args); :baz; end
    @creator.create!(@subject, :foobar,1, 2).twice
    @subject.foobar(1, 2).should == :baz
    @subject.foobar(1, 2).should == :baz
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
  end

  it "sets after_call on the scenario when passed a block" do
    real_value = Object.new
    (class << @subject; self; end).class_eval do
      define_method(:foobar) {real_value}
    end
    @creator.create!(@subject, :foobar, 1, 2) do |value|
      mock(value).a_method {99}
      value
    end

    return_value = @subject.foobar(1, 2)
    return_value.should === return_value
    return_value.a_method.should == 99
  end
end

describe ScenarioCreator, "#create! using stub strategy with probe" do
  it_should_behave_like "RR::ScenarioCreator"

  before do
    @creator.stub
    @creator.probe
  end

  it "sets up a scenario with passed in arguments" do
    def @subject.foobar(*args); :baz; end
    @creator.create!(@subject, :foobar, 1, 2)
    proc do
      @subject.foobar
    end.should raise_error(Errors::ScenarioNotFoundError)
  end

  it "sets expectations on the subject while calling the original method" do
    def @subject.foobar(*args); :baz; end
    @creator.create!(@subject, :foobar, 1, 2) {:new_value}
    10.times do
      @subject.foobar(1, 2).should == :new_value
    end
  end

  it "sets after_call on the scenario when passed a block" do
    real_value = Object.new
    (class << @subject; self; end).class_eval do
      define_method(:foobar) {real_value}
    end
    @creator.create!(@subject, :foobar, 1, 2) do |value|
      mock(value).a_method {99}
      value
    end

    return_value = @subject.foobar(1, 2)
    return_value.should === return_value
    return_value.a_method.should == 99
  end
end
end