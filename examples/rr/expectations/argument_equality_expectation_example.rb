dir = File.dirname(__FILE__)
require "#{dir}/../../example_helper"

module RR
module Expectations
  describe ArgumentEqualityExpectation, "#exact_match?" do
    before do
      @expectation = ArgumentEqualityExpectation.new(1, 2, 3)
    end

    it "returns true when all arguments exactly match" do
      @expectation.should be_exact_match(1, 2, 3)
      @expectation.should_not be_exact_match(1, 2)
      @expectation.should_not be_exact_match(1)
      @expectation.should_not be_exact_match()
      @expectation.should_not be_exact_match("does not match")
    end
  end

  describe ArgumentEqualityExpectation, "#wildcard_match?" do
    it "returns true when all arguments match the wildcard rules" do
      @expectation = ArgumentEqualityExpectation.new(ArgumentEqualityExpectation::Anything.new)
      @expectation.should be_wildcard_match(1, 2, 3)
      @expectation.should be_wildcard_match("whatever")
      @expectation.should be_wildcard_match("whatever", "else")
    end

    it "returns true when exact match" do
      @expectation = ArgumentEqualityExpectation.new(1, 2)
      @expectation.should be_wildcard_match(1, 2)
      @expectation.should_not be_wildcard_match(1)
      @expectation.should_not be_wildcard_match("whatever", "else")
    end
  end

  describe ArgumentEqualityExpectation, "#verify_input with no arguments" do
    before do
      @expectation = ArgumentEqualityExpectation.new
    end

    it "ensures there are no passed in arguments" do
      proc {@expectation.verify_input(1)}.should raise_error(
        ArgumentEqualityExpectationError,
        "1 argument passed in. Expected 0."
      )

      @expectation.verify_input
    end
  end

  describe ArgumentEqualityExpectation, "#verify_input with one argument" do
    before do
      @expectation = ArgumentEqualityExpectation.new(2)
    end

    it "ensures the arguments match" do
      @expectation.verify_input(2)
      proc {@expectation.verify_input(1)}.should raise_error(
        ArgumentEqualityExpectationError,
        "1 is not 2"
      )
      proc {@expectation.verify_input(:wrong)}.should raise_error(
        ArgumentEqualityExpectationError,
        ":wrong is not 2"
      )
      proc {@expectation.verify_input('wrong string')}.should raise_error(
        ArgumentEqualityExpectationError,
        '"wrong string" is not 2'
      )
      wrong_obj = Object.new
      proc {@expectation.verify_input(wrong_obj)}.should raise_error(
        ArgumentEqualityExpectationError,
        "#{wrong_obj.inspect} is not 2"
      )
    end
  end

  describe ArgumentEqualityExpectation, "#verify_input with multiple arguments" do
    before do
      @expectation = ArgumentEqualityExpectation.new(1, 2)
    end

    it "ensures the arguments match the first argument" do
      @expectation.verify_input(1, 2)
      proc {@expectation.verify_input(2, 2)}.should raise_error(
        ArgumentEqualityExpectationError,
        "2 is not 1"
      )
      proc {@expectation.verify_input(:wrong, 2)}.should raise_error(
        ArgumentEqualityExpectationError,
        ":wrong is not 1"
      )
      proc {@expectation.verify_input('wrong string', 2)}.should raise_error(
        ArgumentEqualityExpectationError,
        '"wrong string" is not 1'
      )
      wrong_obj = Object.new
      proc {@expectation.verify_input(wrong_obj, 2)}.should raise_error(
        ArgumentEqualityExpectationError,
        "#{wrong_obj.inspect} is not 1"
      )
    end

    it "ensures the arguments match the second argument" do
      @expectation.verify_input(1, 2)
      proc {@expectation.verify_input(1, 1)}.should raise_error(
        ArgumentEqualityExpectationError,
        "1 is not 2"
      )
      proc {@expectation.verify_input(1, :wrong)}.should raise_error(
        ArgumentEqualityExpectationError,
        ":wrong is not 2"
      )
      proc {@expectation.verify_input(1, 'wrong string')}.should raise_error(
        ArgumentEqualityExpectationError,
        '"wrong string" is not 2'
      )
      wrong_obj = Object.new
      proc {@expectation.verify_input(1, wrong_obj)}.should raise_error(
        ArgumentEqualityExpectationError,
        "#{wrong_obj.inspect} is not 2"
      )
    end
  end

  describe ArgumentEqualityExpectation, "#verify_input with any arguments" do
    before do
      @expectation = ArgumentEqualityExpectation.new(
        ArgumentEqualityExpectation::Anything.new
      )
    end

    it "ensures there are no passed in arguments" do
      @expectation.verify_input(1)
      @expectation.verify_input(1,2,3,4,5)
      @expectation.verify_input("whatever")
      @expectation.verify_input
    end
  end
end
end
