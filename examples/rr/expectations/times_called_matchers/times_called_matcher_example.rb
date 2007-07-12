require "examples/example_helper"

module RR
module TimesCalledMatchers
  describe TimesCalledMatcher, "#error_message" do
    before do
      @times = 3
      @matcher = TimesCalledMatcher.new(@times)
    end

    it "has an error message" do
      @matcher.error_message(5).should == (
        "Called 5 times. Expected 3 times."
      )
    end
  end

  describe TimesCalledMatcher, "#==" do
    before do
      @times = 3
      @matcher = TimesCalledMatcher.new(@times)
    end

    it "returns true when other is the same class and times are ==" do
      @matcher.should == TimesCalledMatcher.new(@times)
    end

    it "returns false when other is a different class and times are ==" do
      @matcher.should_not == IntegerMatcher.new(@times)
    end

    it "returns false when is the same class and times are not ==" do
      @matcher.should_not == TimesCalledMatcher.new(1)
    end
  end
end
end
