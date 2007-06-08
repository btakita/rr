dir = File.dirname(__FILE__)
require "#{dir}/../../example_helper"

describe "RR::Expectations::ArgumentEqualityExpectation", "#verify_input with no arguments" do
  before do
    @expectation = RR::Expectations::ArgumentEqualityExpectation.new
  end

  it "ensures there are no passed in arguments" do
    proc {@expectation.verify_input(1)}.should raise_error(
      RR::Expectations::ArgumentEqualityExpectationError,
      "1 argument passed in. Expected 0."
    )

    @expectation.verify_input
  end
end

describe "RR::Expectations::ArgumentEqualityExpectation", "#verify_input with one argument" do
  before do
    @expectation = RR::Expectations::ArgumentEqualityExpectation.new(2)
  end

  it "ensures the arguments match" do
    @expectation.verify_input(2)
    proc {@expectation.verify_input(1)}.should raise_error(
      RR::Expectations::ArgumentEqualityExpectationError,
      "1 is not 2"
    )
    proc {@expectation.verify_input(:wrong)}.should raise_error(
      RR::Expectations::ArgumentEqualityExpectationError,
      ":wrong is not 2"
    )
    proc {@expectation.verify_input('wrong string')}.should raise_error(
      RR::Expectations::ArgumentEqualityExpectationError,
      '"wrong string" is not 2'
    )
    wrong_obj = Object.new
    proc {@expectation.verify_input(wrong_obj)}.should raise_error(
      RR::Expectations::ArgumentEqualityExpectationError,
      "#{wrong_obj.inspect} is not 2"
    )
  end
end

describe "RR::Expectations::ArgumentEqualityExpectation", "#verify_input with multiple arguments" do
  before do
    @expectation = RR::Expectations::ArgumentEqualityExpectation.new(1, 2)
  end

  it "ensures the arguments match the first argument" do
    @expectation.verify_input(1, 2)
    proc {@expectation.verify_input(2, 2)}.should raise_error(
      RR::Expectations::ArgumentEqualityExpectationError,
      "2 is not 1"
    )
    proc {@expectation.verify_input(:wrong, 2)}.should raise_error(
      RR::Expectations::ArgumentEqualityExpectationError,
      ":wrong is not 1"
    )
    proc {@expectation.verify_input('wrong string', 2)}.should raise_error(
      RR::Expectations::ArgumentEqualityExpectationError,
      '"wrong string" is not 1'
    )
    wrong_obj = Object.new
    proc {@expectation.verify_input(wrong_obj, 2)}.should raise_error(
      RR::Expectations::ArgumentEqualityExpectationError,
      "#{wrong_obj.inspect} is not 1"
    )
  end

  it "ensures the arguments match the second argument" do
    @expectation.verify_input(1, 2)
    proc {@expectation.verify_input(1, 1)}.should raise_error(
      RR::Expectations::ArgumentEqualityExpectationError,
      "1 is not 2"
    )
    proc {@expectation.verify_input(1, :wrong)}.should raise_error(
      RR::Expectations::ArgumentEqualityExpectationError,
      ":wrong is not 2"
    )
    proc {@expectation.verify_input(1, 'wrong string')}.should raise_error(
      RR::Expectations::ArgumentEqualityExpectationError,
      '"wrong string" is not 2'
    )
    wrong_obj = Object.new
    proc {@expectation.verify_input(1, wrong_obj)}.should raise_error(
      RR::Expectations::ArgumentEqualityExpectationError,
      "#{wrong_obj.inspect} is not 2"
    )
  end
end

describe "RR::Expectations::ArgumentEqualityExpectation", "#verify_input with any arguments" do
  before do
    @expectation = RR::Expectations::ArgumentEqualityExpectation.new(
      RR::Expectations::ArgumentEqualityExpectation::Anything.new
    )
  end

  it "ensures there are no passed in arguments" do
    @expectation.verify_input(1)
    @expectation.verify_input(1,2,3,4,5)
    @expectation.verify_input("whatever")
    @expectation.verify_input
  end
end
