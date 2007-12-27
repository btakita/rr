require "spec/spec_helper"

module RR
module Expectations
  describe ArgumentEqualityExpectation, "#exact_match? with is_a argument" do
    before do
      @expectation = ArgumentEqualityExpectation.new(boolean)
    end
    
    it "returns true when passed in an IsA module" do
      @expectation.should be_exact_match(WildcardMatchers::Boolean.new)
    end

    it "returns false otherwise" do
      @expectation.should_not be_exact_match("hello")
      @expectation.should_not be_exact_match(:hello)
      @expectation.should_not be_exact_match(1)
      @expectation.should_not be_exact_match(nil)
      @expectation.should_not be_exact_match(true)
      @expectation.should_not be_exact_match()
    end
  end

  describe ArgumentEqualityExpectation, "#wildcard_match? with is_a Boolean argument" do
    before do
      @expectation = ArgumentEqualityExpectation.new(boolean)
    end

    it "returns true when passed a Boolean" do
      @expectation.should be_wildcard_match(true)
      @expectation.should be_wildcard_match(false)
    end

    it "returns false when not passed a Boolean" do
      @expectation.should_not be_wildcard_match(:not_a_boolean)
    end

    it "returns true when an exact match" do
      @expectation.should be_wildcard_match(boolean)
    end

    it "returns false when not passed correct number of arguments" do
      @expectation.should_not be_wildcard_match()
      @expectation.should_not be_wildcard_match(true, false)
    end
  end
end
end
