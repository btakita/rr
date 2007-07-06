dir = File.dirname(__FILE__)
require "#{dir}/../../example_helper"

module RR
module Expectations
  describe ArgumentEqualityExpectation, "#exact_match? with is_a argument" do
    before do
      @expectation = ArgumentEqualityExpectation.new(is_a(String))
    end
    
    it "returns true when passed in an IsA module" do
      @expectation.should be_exact_match(WildcardMatchers::IsA.new(String))
    end

    it "returns false when passed in an IsA object with a different module" do
      @expectation.should_not be_exact_match(WildcardMatchers::IsA.new(Integer))
    end

    it "returns false otherwise" do
      @expectation.should_not be_exact_match("hello")
      @expectation.should_not be_exact_match(:hello)
      @expectation.should_not be_exact_match(1)
      @expectation.should_not be_exact_match(nil)
      @expectation.should_not be_exact_match()
    end
  end

  describe ArgumentEqualityExpectation, "#wildcard_match? with is_a String argument" do
    before do
      @expectation = ArgumentEqualityExpectation.new(is_a(String))
    end

    it "returns true when passed a String" do
      @expectation.should be_wildcard_match("Hello")
    end

    it "returns false when not passed a String" do
      @expectation.should_not be_wildcard_match(:not_a_string)
    end

    it "returns true when an exact match" do
      @expectation.should be_wildcard_match(is_a(String))
    end

    it "returns false when not passed correct number of arguments" do
      @expectation.should_not be_wildcard_match()
      @expectation.should_not be_wildcard_match("one", "two")
    end
  end
end
end
