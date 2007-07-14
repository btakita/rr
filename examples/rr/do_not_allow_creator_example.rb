require "examples/example_helper"

module RR
describe DoNotAllowCreator, :shared => true do
  before(:each) do
    @space = Space.new
    @subject = Object.new
  end

  it "initializes creator with passed in object" do
    class << @creator
      attr_reader :subject
    end
    @creator.subject.should === @subject
  end
end

describe DoNotAllowCreator, ".new" do
  it_should_behave_like "RR::DoNotAllowCreator"

  before do
    @creator = DoNotAllowCreator.new(@space, @subject)
  end

  it "clears out all methods from creator" do
    creator_subclass = Class.new(DoNotAllowCreator) do
      def i_should_be_a_scenario
      end
    end
    creator_subclass.instance_methods.should include('i_should_be_a_scenario')

    creator = creator_subclass.new(@space, @subject)
    creator.i_should_be_a_scenario.should be_instance_of(Scenario)
  end
end

describe DoNotAllowCreator, ".new with block" do
  it_should_behave_like "RR::DoNotAllowCreator"

  before do
    @creator = DoNotAllowCreator.new(@space, @subject) do |c|
      c.any_args
      c.no_args.with_no_args
      c.with_args(1, 2)
    end
  end

  it "raises TimesCalledError when any_args is called with no arguments" do
    proc {@subject.any_args}.should raise_error(Errors::TimesCalledError)
  end

  it "raises TimesCalledError when any_args is called with arguments" do
    proc {@subject.any_args(1, 2)}.should raise_error(Errors::TimesCalledError)
  end

  it "raises TimesCalledError when no_args is called with no arguments" do
    proc {@subject.no_args}.should raise_error(Errors::TimesCalledError)
  end

  it "does not raise TimesCalledError when no_args is called with arguments" do
    proc {@subject.no_args(1, 2)}.should raise_error(Errors::ScenarioNotFoundError)
  end

  it "raises TimesCalledError when any_args is called with no arguments" do
    proc {@subject.with_args}.should raise_error(Errors::ScenarioNotFoundError)
  end

  it "raises TimesCalledError when any_args is called with arguments" do
    proc {@subject.any_args(1, 2)}.should raise_error(Errors::TimesCalledError)
  end

  it "clears out all methods from creator" do
    creator_subclass = Class.new(DoNotAllowCreator) do
      def i_should_be_a_scenario
      end
    end
    creator_subclass.instance_methods.should include('i_should_be_a_scenario')

    creator = creator_subclass.new(@space, @subject)
    creator.i_should_be_a_scenario.should be_instance_of(Scenario)
  end
end

describe DoNotAllowCreator, "#method_missing" do
  it_should_behave_like "RR::DoNotAllowCreator"

  before do
    @subject = Object.new
    @creator = DoNotAllowCreator.new(@space, @subject)
  end

  it "sets expectation for method to never be called with any arguments when on arguments passed in" do
    @creator.foobar
    proc {@subject.foobar}.should raise_error(Errors::TimesCalledError)
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
  end

  it "sets expectation for method to never be called with passed in arguments" do
    @creator.foobar(1, 2)
    proc {@subject.foobar}.should raise_error(Errors::ScenarioNotFoundError)
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
  end

  it "sets expectation for method to never be called with no arguments when with_no_args is set" do
    @creator.foobar.with_no_args
    proc {@subject.foobar}.should raise_error(Errors::TimesCalledError)
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::ScenarioNotFoundError)
  end
end

end