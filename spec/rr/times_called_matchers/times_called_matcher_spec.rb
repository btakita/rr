require "spec/spec_helper"

module RR
module TimesCalledMatchers
  describe TimesCalledMatcher, ".create when passed a TimesCalledMatcher" do
    it "returns the passed in argument" do
      matcher = TimesCalledMatcher.new(5)
      TimesCalledMatcher.create(matcher).should === matcher
    end
  end

  describe TimesCalledMatcher, ".create when passed an unsupported type" do
    it "raises an ArgumentError" do
      matcher = Object.new
      proc do
        TimesCalledMatcher.create(matcher)
      end.should raise_error(ArgumentError, "There is no TimesCalledMatcher for #{matcher.inspect}.")
    end
  end

  describe TimesCalledMatcher, "#error_message" do
    before do
      @times = 3
      @matcher = TimesCalledMatcher.new(@times)
    end

    it "has an error message" do
      @matcher.error_message(5).should == (
        "Called 5 times.\nExpected 3 times."
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
