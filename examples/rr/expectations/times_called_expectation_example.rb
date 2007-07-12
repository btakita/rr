require "examples/example_helper"

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
    @expectation.attempt!
    @expectation.verify.should == false
    @expectation.attempt!
    @expectation.verify.should == true
  end

  it "returns true when times called falls within a range" do
    @expectation = TimesCalledExpectation.new(1..2)

    @expectation.verify.should == false
    @expectation.attempt!
    @expectation.verify.should == true
    @expectation.attempt!
    @expectation.verify.should == true
  end

  it "matches a block" do
    @expectation = TimesCalledExpectation.new {|value| value == 2}

    @expectation.verify.should == false
    @expectation.attempt!
    @expectation.verify.should == false
    @expectation.attempt!
    @expectation.verify.should == true
    @expectation.attempt!
    @expectation.verify.should == false
  end
end

describe TimesCalledExpectation, "#verify! when passed an Integer (2)" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

  before do
    @expectation = TimesCalledExpectation.new(2)
    @expected_line = __LINE__ - 1
  end

  it "passes after attempt! called 2 times" do
    @expectation.attempt!
    @expectation.attempt!
    @expectation.verify!
  end

  it "fails after attempt! called 1 time" do
    @expectation.attempt!
    proc {@expectation.verify!}.should raise_error(
      Errors::TimesCalledError,
      "Called 1 time. Expected 2."
    )
  end

  it "can't be called when attempt! is called 3 times" do
    @expectation.attempt!
    @expectation.attempt!
    proc do
      @expectation.attempt!
    end.should raise_error(Errors::TimesCalledError, "Called 3 times. Expected 2.")
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

  it "has an error message that includes the number of times called and expected number of times" do
    proc do
      @expectation.verify!
    end.should raise_error(Errors::TimesCalledError, "Called 0 times. Expected 2.")
  end
end

describe TimesCalledExpectation, "#verify! when passed a Range (1..2)" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

  before do
    @expectation = TimesCalledExpectation.new(1..2)
  end

  it "passes after attempt! called 1 time" do
    @expectation.attempt!
    @expectation.verify!
  end

  it "passes after attempt! called 2 times" do
    @expectation.attempt!
    @expectation.attempt!
    @expectation.verify!
  end

  it "can't be called when attempt! is called 3 times" do
    @expectation.attempt!
    @expectation.attempt!
    proc do
      @expectation.attempt!
    end.should raise_error(Errors::TimesCalledError, "Called 3 times. Expected 1..2.")
  end
end

describe TimesCalledExpectation, "#verify! when passed a block (== 2 times)" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

  before do
    @expectation = TimesCalledExpectation.new {|value| value == 2}
  end

  it "passes after attempt! called 2 times" do
    @expectation.attempt!
    @expectation.attempt!
    @expectation.verify!
  end

  it "fails after attempt! called 1 time" do
    @expectation.attempt!
    proc {@expectation.verify!}.should raise_error(Errors::TimesCalledError)
  end

  it "fails after attempt! called 3 times" do
    @expectation.attempt!
    @expectation.attempt!
    @expectation.attempt!
    proc {@expectation.verify!}.should raise_error(Errors::TimesCalledError)
  end
end

describe TimesCalledExpectation, "#attempt! for an integer expectation" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

  it "raises error when attempt! called more than the expected number of times" do
    @expectation = TimesCalledExpectation.new(1)
    @expectation.attempt!
    raises_expectation_error {@expectation.attempt!}
  end
end

describe TimesCalledExpectation, "#attempt! for a range expectation" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

  it "raises error when attempt! called more than range permits" do
    @expectation = TimesCalledExpectation.new(1..2)
    @expectation.attempt!
    @expectation.attempt!
    raises_expectation_error {@expectation.attempt!}
  end
end

describe TimesCalledExpectation, "#attempt! for a proc expectation" do
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
