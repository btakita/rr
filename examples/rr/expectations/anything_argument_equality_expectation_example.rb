dir = File.dirname(__FILE__)
require "#{dir}/../../example_helper"

module RR
module Expectations
  describe ArgumentEqualityError, "#exact_match? with anything argument" do
    before do
      @expectation = ArgumentEqualityError.new(anything)
    end
    
    it "returns true when passed in an Anything module" do
      @expectation.should be_exact_match(WildcardMatchers::Anything.new)
    end

    it "returns false otherwise" do
      @expectation.should_not be_exact_match("hello")
      @expectation.should_not be_exact_match(:hello)
      @expectation.should_not be_exact_match(1)
      @expectation.should_not be_exact_match(nil)
      @expectation.should_not be_exact_match()
    end
  end

  describe ArgumentEqualityError, "#wildcard_match? with is_a String argument" do
    before do
      @expectation = ArgumentEqualityError.new(anything)
    end

    it "returns true when passed correct number of arguments" do
      @expectation.should be_wildcard_match(Object.new)
    end

    it "returns false when not passed correct number of arguments" do
      @expectation.should_not be_wildcard_match()
      @expectation.should_not be_wildcard_match(Object.new, Object.new)
    end
  end
end
end
