require "examples/example_helper"

module RR
module TimesCalledMatchers
  describe TimesCalledMatcher, ".create when passed a AnyTimesMatcher" do
    it "returns the passed in argument" do
      matcher = AnyTimesMatcher.new
      TimesCalledMatcher.create(matcher).should === matcher
    end
  end

  describe AnyTimesMatcher, "#possible_match?" do
    before do
      @matcher = AnyTimesMatcher.new
    end

    it "always returns true" do
      @matcher.should be_possible_match(0)
      @matcher.should be_possible_match(99999)
    end
  end

  describe AnyTimesMatcher, "#matches?" do
    before do
      @matcher = AnyTimesMatcher.new
    end

    it "always returns true" do
      @matcher.should be_matches(0)
      @matcher.should be_matches(99999)
    end
  end

  describe AnyTimesMatcher, "#attempt?" do
    before do
      @matcher = AnyTimesMatcher.new
    end

    it "always returns true" do
      @matcher.should be_attempt(0)
      @matcher.should be_attempt(99999)
    end
  end  

  describe AnyTimesMatcher, "#error_message" do
    before do
      @matcher = AnyTimesMatcher.new
    end

    it "has an error message" do
      @matcher.error_message(2).should == (
        "Called 2 times.\nExpected any number of times."
      )
    end
  end
end
end
