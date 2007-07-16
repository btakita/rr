require "examples/example_helper"

module RR
module TimesCalledMatchers
  describe RangeMatcher, :shared => true do
    before do
      @times = 2..4
      @matcher = RangeMatcher.new(@times)
    end
  end

  describe TimesCalledMatcher, ".create when passed a IntegerMatcher" do
    it "returns the passed in argument" do
      matcher = RangeMatcher.new(2..4)
      TimesCalledMatcher.create(matcher).should === matcher
    end
  end

  describe TimesCalledMatcher, ".create when passed a Integer" do
    it "returns RangeMatcher" do
      TimesCalledMatcher.create(2..4).should == RangeMatcher.new(2..4)
    end
  end

  describe RangeMatcher, "#possible_match?" do
    it_should_behave_like "RR::TimesCalledMatchers::RangeMatcher"

    it "returns true when times called < start of range" do
      @matcher.should be_possible_match(1)
    end

    it "returns true when times called in range" do
      @matcher.should be_possible_match(2)
      @matcher.should be_possible_match(3)
      @matcher.should be_possible_match(4)
    end

    it "returns false when times called > end of range" do
      @matcher.should_not be_possible_match(5)
    end
  end

  describe RangeMatcher, "#matches?" do
    it_should_behave_like "RR::TimesCalledMatchers::RangeMatcher"

    it "returns false when times_called less than start of range" do
      @matcher.should_not be_matches(1)
    end

    it "returns true when times_called in range" do
      @matcher.should be_matches(2)
      @matcher.should be_matches(3)
      @matcher.should be_matches(4)
    end

    it "returns false when times_called > end of range" do
      @matcher.should_not be_matches(5)
    end
  end

  describe RangeMatcher, "#attempt?" do
    it_should_behave_like "RR::TimesCalledMatchers::RangeMatcher"

    it "returns true when less than start of range" do
      @matcher.should be_attempt(1)
    end

    it "returns true when in range" do
      @matcher.should be_attempt(2)
      @matcher.should be_attempt(3)
      @matcher.should be_attempt(4)
    end

    it "returns false when > end of range" do
      @matcher.should_not be_attempt(5)
    end
  end

  describe RangeMatcher, "#terminal?" do
    it_should_behave_like "RR::TimesCalledMatchers::RangeMatcher"

    it "returns true" do
      @matcher.should be_terminal
    end
  end

  describe RangeMatcher, "#error_message" do
    it_should_behave_like "RR::TimesCalledMatchers::RangeMatcher"

    it "has an error message" do
      @matcher.error_message(1).should == (
        "Called 1 time.\nExpected 2..4 times."
      )
    end
  end
end
end
