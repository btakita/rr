require "examples/example_helper"

module RR
describe ScenarioCreator, :shared => true do
  before(:each) do
    @space = Space.new
    @subject = Object.new
    @creator = ScenarioCreator.new(@space, @subject)
  end

  it "initializes creator with passed in object" do
    @creator.subject.should === @subject
  end
end

describe ScenarioCreator, "#mock" do
  it_should_behave_like "RR::ScenarioCreator"

  it "raises error when stub called before" do
    @creator.stub
    proc do
      @creator.mock
    end.should raise_error(
      Errors::ScenarioDefinitionError,
      "This Scenario is already a stub. It cannot be a mock."
    )
  end
end

describe ScenarioCreator, "#stub" do
  it_should_behave_like "RR::ScenarioCreator"

  it "raises error when mock called before" do
    @creator.mock
    proc do
      @creator.stub
    end.should raise_error(
      Errors::ScenarioDefinitionError,
      "This Scenario is already a mock. It cannot be a stub."
    )
  end
end

describe ScenarioCreator, "#create! using mock strategy" do
  it_should_behave_like "RR::ScenarioCreator"
  
  before do
    @creator.mock
  end

  it "sets expectations on the subject" do
    @creator.create!(:foobar, 1, 2) {:baz}.twice

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
    @creator.create!(:foobar) {:baz}
    @subject.foobar.should == :baz
  end

  it "stubs the subject mapping passed in args with the output" do
    @creator.create!(:foobar, 1, 2) {:one_two}
    @creator.create!(:foobar, 1) {:one}
    @creator.create!(:foobar) {:nothing}
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
    @creator.create!(:foobar)
    proc {@subject.foobar}.should raise_error(Errors::TimesCalledError)
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
  end

  it "sets expectation for method to never be called with passed in arguments" do
    @creator.create!(:foobar, 1, 2)
    proc {@subject.foobar}.should raise_error(Errors::ScenarioNotFoundError)
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
  end

  it "sets expectation for method to never be called with no arguments when with_no_args is set" do
    @creator.create!(:foobar).with_no_args
    proc {@subject.foobar}.should raise_error(Errors::TimesCalledError)
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::ScenarioNotFoundError)
  end
end

describe ScenarioCreator, "#create! using mock_probe strategy" do
  it_should_behave_like "RR::ScenarioCreator"

  before do
    @creator.mock_probe
  end

  it "sets expectations on the subject while calling the original method" do
    def @subject.foobar(*args); :baz; end
    @creator.create!(:foobar,1, 2).twice
    @subject.foobar(1, 2).should == :baz
    @subject.foobar(1, 2).should == :baz
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
  end

  it "sets after_call on the scenario when passed a block" do
    real_value = Object.new
    (class << @subject; self; end).class_eval do
      define_method(:foobar) {real_value}
    end
    @creator.create!(:foobar, 1, 2) do |value|
      mock(value).a_method {99}
      value
    end

    return_value = @subject.foobar(1, 2)
    return_value.should === return_value
    return_value.a_method.should == 99
  end
end

describe ScenarioCreator, "#create! using stub_probe strategy" do
  it_should_behave_like "RR::ScenarioCreator"

  before do
    @creator.stub_probe
  end

  it "sets up a scenario with passed in arguments" do
    def @subject.foobar(*args); :baz; end
    @creator.create!(:foobar, 1, 2)
    proc do
      @subject.foobar
    end.should raise_error(Errors::ScenarioNotFoundError)
  end

  it "sets expectations on the subject while calling the original method" do
    def @subject.foobar(*args); :baz; end
    @creator.create!(:foobar, 1, 2) {:new_value}
    10.times do
      @subject.foobar(1, 2).should == :new_value
    end
  end

  it "sets after_call on the scenario when passed a block" do
    real_value = Object.new
    (class << @subject; self; end).class_eval do
      define_method(:foobar) {real_value}
    end
    @creator.create!(:foobar, 1, 2) do |value|
      mock(value).a_method {99}
      value
    end

    return_value = @subject.foobar(1, 2)
    return_value.should === return_value
    return_value.a_method.should == 99
  end
end
end