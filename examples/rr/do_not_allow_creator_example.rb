dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

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

  it "raises TimesCalledExpectationError when any_args is called with no arguments" do
    proc {@subject.any_args}.should raise_error(Expectations::TimesCalledExpectationError)
  end

  it "raises TimesCalledExpectationError when any_args is called with arguments" do
    proc {@subject.any_args(1, 2)}.should raise_error(Expectations::TimesCalledExpectationError)
  end

  it "raises TimesCalledExpectationError when no_args is called with no arguments" do
    proc {@subject.no_args}.should raise_error(Expectations::TimesCalledExpectationError)
  end

  it "does not raise TimesCalledExpectationError when no_args is called with arguments" do
    proc {@subject.no_args(1, 2)}.should raise_error(ScenarioNotFoundError)
  end

  it "raises TimesCalledExpectationError when any_args is called with no arguments" do
    proc {@subject.with_args}.should raise_error(ScenarioNotFoundError)
  end

  it "raises TimesCalledExpectationError when any_args is called with arguments" do
    proc {@subject.any_args(1, 2)}.should raise_error(Expectations::TimesCalledExpectationError)
  end
end

#describe DoNotAllowCreator, "#method_missing" do
#  it_should_behave_like "RR::DoNotAllowCreator"
#
#  before do
#    @subject = Object.new
#    @creator = DoNotAllowCreator.new(@space, @subject)
#  end
#
#  it "sets expectations on the subject" do
#    @creator.foobar(1, 2) {:baz}.twice
#
#    @subject.foobar(1, 2).should == :baz
#    @subject.foobar(1, 2).should == :baz
#    proc {@subject.foobar(1, 2)}.should raise_error(Expectations::TimesCalledExpectationError)
#  end
#end
#
end