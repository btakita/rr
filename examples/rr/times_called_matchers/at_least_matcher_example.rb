require "examples/example_helper"

module RR
module TimesCalledMatchers
  describe TimesCalledMatcher, ".create when passed a AtLeastMatcher" do
    it "returns the passed in argument" do
      matcher = AtLeastMatcher.new(5)
      TimesCalledMatcher.create(matcher).should === matcher
    end
  end

  describe AtLeastMatcher, "#possible_match?" do
    before do
      @times = 3
      @matcher = AtLeastMatcher.new(@times)
    end

    it "always returns true" do
      @matcher.should be_possible_match(99999)
    end
  end

  describe AtLeastMatcher, "#matches?" do
    before do
      @times = 3
      @matcher = AtLeastMatcher.new(@times)
    end

    it "returns false when times_called less than times" do
      @matcher.should_not be_matches(2)
    end

    it "returns true when times_called == times" do
      @matcher.should be_matches(3)
    end

    it "returns true when times_called > times" do
      @matcher.should be_matches(4)
    end
  end

  describe AtLeastMatcher, "#attempt?" do
    before do
      @times = 3
      @matcher = AtLeastMatcher.new(@times)
    end

    it "always returns true" do
      @matcher.should be_attempt(1)
      @matcher.should be_attempt(100000)
    end
  end  

  describe AtLeastMatcher, "#error_message" do
    before do
      @times = 3
      @matcher = AtLeastMatcher.new(@times)
    end

    it "has an error message" do
      @matcher.error_message(2).should == (
        "Called 2 times.\nExpected at least 3 times."
      )
    end
  end
end
end
