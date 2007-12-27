require "spec/example_helper"

module RR
module Expectations
  describe ArgumentEqualityExpectation, "expected_arguments" do
    before do
      @expectation = ArgumentEqualityExpectation.new(1, 2, 3)
    end

    it "returns the passed in expected_arguments" do
      @expectation.expected_arguments.should == [1, 2, 3]
    end
  end

  describe ArgumentEqualityExpectation, "==" do
    before do
      @expectation = ArgumentEqualityExpectation.new(1, 2, 3)
    end
    
    it "returns true when passed in expected_arguments are equal" do
      @expectation.should == ArgumentEqualityExpectation.new(1, 2, 3)
    end

    it "returns false when passed in expected_arguments are not equal" do
      @expectation.should_not == ArgumentEqualityExpectation.new(1, 2)
      @expectation.should_not == ArgumentEqualityExpectation.new(1)
      @expectation.should_not == ArgumentEqualityExpectation.new(:something)
      @expectation.should_not == ArgumentEqualityExpectation.new()
    end
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
    it "returns false when not exact match" do
      @expectation = ArgumentEqualityExpectation.new(1)
      @expectation.should_not be_wildcard_match(1, 2, 3)
      @expectation.should_not be_wildcard_match("whatever")
      @expectation.should_not be_wildcard_match("whatever", "else")
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
