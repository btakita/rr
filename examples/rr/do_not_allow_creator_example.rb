require "examples/example_helper"

module RR
describe DoNotAllowCreator, :shared => true do
  before(:each) do
    @space = Space.new
    @subject = Object.new
  end

  it "initializes creator with passed in object" do
    @creator.subject.should === @subject
  end
end

describe DoNotAllowCreator, "#create" do
  it_should_behave_like "RR::DoNotAllowCreator"

  before do
    @subject = Object.new
    @creator = DoNotAllowCreator.new(@space, @subject)
  end

  it "sets expectation for method to never be called with any arguments when on arguments passed in" do
    @creator.create(:foobar)
    proc {@subject.foobar}.should raise_error(Errors::TimesCalledError)
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
  end

  it "sets expectation for method to never be called with passed in arguments" do
    @creator.create(:foobar, 1, 2)
    proc {@subject.foobar}.should raise_error(Errors::ScenarioNotFoundError)
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
  end

  it "sets expectation for method to never be called with no arguments when with_no_args is set" do
    @creator.create(:foobar).with_no_args
    proc {@subject.foobar}.should raise_error(Errors::TimesCalledError)
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::ScenarioNotFoundError)
  end
end

end