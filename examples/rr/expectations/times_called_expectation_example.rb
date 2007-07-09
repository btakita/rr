dir = File.dirname(__FILE__)
require "#{dir}/../../example_helper"

module RR
module Expectations
describe TimesCalledExpectation, :shared => true do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    @double = @space.create_double(@object, @method_name)
    @scenario = @space.create_scenario(@double)
    @scenario.with_any_args
  end

  def raises_expectation_error(&block)
    proc {block.call}.should raise_error(Errors::TimesCalledError)
  end
end

describe TimesCalledExpectation, ".new" do
  it "doesn't accept both an argument and a block" do
    proc do
      TimesCalledExpectation.new(2) {|value| value == 2}
    end.should raise_error(ArgumentError, "Cannot pass in both an argument and a block")
  end
end

describe TimesCalledExpectation, "#verify" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

  it "returns true when times called exactly matches an integer" do
    @expectation = TimesCalledExpectation.new(2)
    @expectation.verify.should == false
    @expectation.verify_input
    @expectation.verify.should == false
    @expectation.verify_input
    @expectation.verify.should == true
  end

  it "returns true when times called falls within a range" do
    @expectation = TimesCalledExpectation.new(1..2)

    @expectation.verify.should == false
    @expectation.verify_input
    @expectation.verify.should == true
    @expectation.verify_input
    @expectation.verify.should == true
  end

  it "matches a block" do
    @expectation = TimesCalledExpectation.new {|value| value == 2}

    @expectation.verify.should == false
    @expectation.verify_input
    @expectation.verify.should == false
    @expectation.verify_input
    @expectation.verify.should == true
    @expectation.verify_input
    @expectation.verify.should == false
  end
end

describe TimesCalledExpectation, "#verify! when passed an Integer (2)" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

  before do
    @expectation = TimesCalledExpectation.new(2)
    @expected_line = __LINE__ - 1
  end

  it "passes after verify_input called 2 times" do
    @expectation.verify_input
    @expectation.verify_input
    @expectation.verify!
  end

  it "fails after verify_input called 1 time" do
    @expectation.verify_input
    proc {@expectation.verify!}.should raise_error(Errors::TimesCalledError)
  end

  it "can't be called when verify_input is called 3 times" do
    @expectation.verify_input
    @expectation.verify_input
    proc do
      @expectation.verify_input
    end.should raise_error(Errors::TimesCalledError)
  end

  it "has a backtrace to where the TimesCalledExpectation was instantiated on failure" do
    error = nil
    begin
      @expectation.verify!
    rescue Errors::TimesCalledError => e
      error = e
    end
    e.backtrace.first.should include(__FILE__)
    e.backtrace.first.should include(":#{@expected_line}")
  end
end

describe TimesCalledExpectation, "#verify! when passed a Range (1..2)" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

  before do
    @expectation = TimesCalledExpectation.new(1..2)
  end

  it "passes after verify_input called 1 time" do
    @expectation.verify_input
    @expectation.verify!
  end

  it "passes after verify_input called 2 times" do
    @expectation.verify_input
    @expectation.verify_input
    @expectation.verify!
  end

  it "can't be called when verify_input is called 3 times" do
    @expectation.verify_input
    @expectation.verify_input
    proc do
      @expectation.verify_input
    end.should raise_error(Errors::TimesCalledError)
  end
end

describe TimesCalledExpectation, "#verify! when passed a block (== 2 times)" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

  before do
    @expectation = TimesCalledExpectation.new {|value| value == 2}
  end

  it "passes after verify_input called 2 times" do
    @expectation.verify_input
    @expectation.verify_input
    @expectation.verify!
  end

  it "fails after verify_input called 1 time" do
    @expectation.verify_input
    proc {@expectation.verify!}.should raise_error(Errors::TimesCalledError)
  end

  it "fails after verify_input called 3 times" do
    @expectation.verify_input
    @expectation.verify_input
    @expectation.verify_input
    proc {@expectation.verify!}.should raise_error(Errors::TimesCalledError)
  end
end

describe TimesCalledExpectation, "#verify_input for an integer expectation" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

  it "raises error when verify_input called more than the expected number of times" do
    @expectation = TimesCalledExpectation.new(1)
    @expectation.verify_input
    raises_expectation_error {@expectation.verify_input}
  end
end

describe TimesCalledExpectation, "#verify_input for a range expectation" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

  it "raises error when verify_input called more than range permits" do
    @expectation = TimesCalledExpectation.new(1..2)
    @expectation.verify_input
    @expectation.verify_input
    raises_expectation_error {@expectation.verify_input}
  end
end

describe TimesCalledExpectation, "#verify_input for a proc expectation" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

  it "lets everything pass" do
    @expectation = TimesCalledExpectation.new {|times| times == 1}
    @object.foobar
    @object.foobar
    @object.foobar
  end
end
end
end
