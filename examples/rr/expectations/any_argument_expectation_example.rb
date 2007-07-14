require "examples/example_helper"

module RR
module Expectations
  describe AnyArgumentExpectation, "==" do
    before do
      @expectation = AnyArgumentExpectation.new
    end

    it "returns true when comparing with another AnyArgumentExpectation" do
      @expectation.should == AnyArgumentExpectation.new
    end

    it "returns false when comparing with ArgumentEqualityExpectation" do
      @expectation.should_not == ArgumentEqualityExpectation.new(1)
    end
  end

  describe AnyArgumentExpectation, "#exact_match?" do
    before do
      @expectation = AnyArgumentExpectation.new
    end

    it "returns false" do
      @expectation.should_not be_exact_match(1, 2, 3)
      @expectation.should_not be_exact_match(1, 2)
      @expectation.should_not be_exact_match(1)
      @expectation.should_not be_exact_match()
      @expectation.should_not be_exact_match("does not match")
    end
  end

  describe AnyArgumentExpectation, "#wildcard_match?" do
    it "returns true" do
      @expectation = AnyArgumentExpectation.new
      @expectation.should be_wildcard_match(1, 2, 3)
      @expectation.should be_wildcard_match("whatever")
      @expectation.should be_wildcard_match("whatever", "else")
    end
  end
end
end
