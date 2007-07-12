require "examples/example_helper"

module RR
module Expectations
describe TimesCalledExpectation, "#verify" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

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