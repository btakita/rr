require "examples/example_helper"

module RR
module Expectations
  describe TimesCalledExpectation, ' with AtMostMatcher', :shared => true do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation"
    
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

  describe TimesCalledExpectation, "#attempt? with AtMostMatcher" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with AtMostMatcher"

    it "returns true when attempted less than expected times" do
      2.times {@expectation.attempt!}
      @expectation.should be_attempt
    end

    it "returns false when attempted expected times" do
      3.times {@expectation.attempt!}
      @expectation.should_not be_attempt
    end

    it "raises error before attempted more than expected times" do
      3.times {@expectation.attempt!}
      proc {@expectation.attempt!}.should raise_error(
        Errors::TimesCalledError  
      )
    end
  end

  describe TimesCalledExpectation, "#attempt! with AtMostMatcher" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with AtMostMatcher"

    it "fails when times called more than times" do
      3.times {@expectation.attempt!}
      proc do
        @expectation.attempt!
      end.should raise_error(Errors::TimesCalledError, "Called 4 times.\nExpected at most 3 times.")
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
