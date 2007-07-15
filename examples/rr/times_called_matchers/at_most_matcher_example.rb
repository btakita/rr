require "examples/example_helper"

module RR
module TimesCalledMatchers
  describe AtMostMatcher, :shared => true do
    before do
      @times = 3
      @matcher = AtMostMatcher.new(@times)
    end
  end

  describe TimesCalledMatcher, ".create when passed a AtMostMatcher" do
    it "returns the passed in argument" do
      matcher = AtMostMatcher.new(5)
      TimesCalledMatcher.create(matcher).should === matcher
    end
  end

  describe AtMostMatcher, "#possible_match?" do
    it_should_behave_like "RR::TimesCalledMatchers::AtMostMatcher"

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

  describe AtMostMatcher, "#matches?" do
    it_should_behave_like "RR::TimesCalledMatchers::AtMostMatcher"

    it "returns true when times_called less than times" do
      @matcher.should be_matches(2)
    end

    it "returns true when times_called == times" do
      @matcher.should be_matches(3)
    end

    it "returns false when times_called > times" do
      @matcher.should_not be_matches(4)
    end
  end

  describe AtMostMatcher, "#attempt?" do
    it_should_behave_like "RR::TimesCalledMatchers::AtMostMatcher"

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

  describe AnyTimesMatcher, "#deterministic?" do
    it_should_behave_like "RR::TimesCalledMatchers::AtMostMatcher"

    it "returns true" do
      @matcher.should be_deterministic
    end
  end
  
  describe AtMostMatcher, "#error_message" do
    it_should_behave_like "RR::TimesCalledMatchers::AtMostMatcher"

    it "has an error message" do
      @matcher.error_message(5).should == (
        "Called 5 times.\nExpected at most 3 times."
      )
    end
  end
end
end
