require "examples/example_helper"

module RR
module Expectations
  describe TimesCalledExpectation, ' with AtMostMatcher', :shared => true do
    before do
      @times = 3
      @at_most = TimesCalledMatchers::AtMostMatcher.new(@times)
      @expectation = TimesCalledExpectation.new(@at_most)
    end
  end

  describe TimesCalledExpectation, "#verify! with AtMostMatcher" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with AtMostMatcher"

    it "returns true when times called == times" do
      3.times {@expectation.attempt!}
      @expectation.verify!
    end

    it "raises error when times called < times" do
      2.times {@expectation.attempt!}
      @expectation.verify!
    end
  end

  describe TimesCalledExpectation, "#attempt! with AtMostMatcher" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with AtMostMatcher"

    it "fails when times called more than times" do
      3.times {@expectation.attempt!}
      proc do
        @expectation.attempt!
      end.should raise_error(Errors::TimesCalledError, "Called 4 times. Expected at most 3 times.")
    end

    it "passes when times called == times" do
      3.times {@expectation.attempt!}
    end

    it "passes when times called < times" do
      @expectation.attempt!
    end
  end
end
end
