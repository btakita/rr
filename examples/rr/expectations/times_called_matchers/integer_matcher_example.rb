require "examples/example_helper"

module RR
module Expectations
module TimesCalledMatchers
  describe IntegerMatcher, "#possible_match?" do
    before do
      @times = 3
      @matcher = IntegerMatcher.new(@times)
    end

    it "returns true when times called < times" do
      @matcher.should be_possible_match(2)
    end

    it "returns true when times called == times" do
      @matcher.should be_possible_match(3)
    end

    it "returns false when times called > times" do
      @matcher.should_not be_possible_match(4)
    end
  end

  describe IntegerMatcher, "#matches?" do
    before do
      @times = 3
      @matcher = IntegerMatcher.new(@times)
    end

    it "returns false when times_called less than times" do
      @matcher.should_not be_matches(2)
    end

    it "returns true when times_called == times" do
      @matcher.should be_matches(3)
    end

    it "returns false when times_called > times" do
      @matcher.should_not be_matches(4)
    end
  end

  describe IntegerMatcher, "#attempt?" do
    before do
      @times = 3
      @matcher = IntegerMatcher.new(@times)
    end

    it "returns true when less than expected times" do
      @matcher.should be_attempt(2)
    end

    it "returns false when == expected times" do
      @matcher.should_not be_attempt(3)
    end

    it "returns false when > expected times" do
      @matcher.should_not be_attempt(4)
    end
  end

  describe IntegerMatcher, "#error_message" do
    before do
      @times = 3
      @matcher = IntegerMatcher.new(@times)
    end

    it "has an error message" do
      @matcher.error_message(2).should == (
        "Called 2 times. Expected 3 times."
      )
    end
  end
end
end
end
