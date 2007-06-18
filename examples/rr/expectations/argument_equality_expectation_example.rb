dir = File.dirname(__FILE__)
require "#{dir}/../../example_helper"

module RR
module Expectations
  describe ArgumentEqualityExpectation, "==" do
    it "returns true when passed in expected_arguments are equal"
  end

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
end
end
