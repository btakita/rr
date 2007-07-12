require "examples/example_helper"

module RR
module Expectations
  describe TimesCalledExpectation, ' with AtLeastMatcher', :shared => true do
    before do
      @times = 3
      @at_least = TimesCalledMatchers::AtLeastMatcher.new(@times)
      @expectation = TimesCalledExpectation.new(@at_least)
    end
  end

  describe TimesCalledExpectation, "#verify! with AtLeastMatcher" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with AtLeastMatcher"

    it "returns true when times called more than times" do
      4.times {@expectation.verify_input}
      @expectation.verify!
    end

    it "returns true when times called == times" do
      3.times {@expectation.verify_input}
      @expectation.verify!
    end

    it "raises error when times called < times" do
      @expectation.verify_input
      proc do
        @expectation.verify!
      end.should raise_error(
        RR::Errors::TimesCalledError,
        "Called 1 time. Expected at least 3 times."
      )
    end
  end

  describe TimesCalledExpectation, "#verify_input with AtLeastMatcher" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with AtLeastMatcher"
    
    it "passes when times called more than times" do
      4.times {@expectation.verify_input}
    end

    it "passes when times called == times" do
      3.times {@expectation.verify_input}
    end

    it "passes when times called < times" do
      @expectation.verify_input
    end
  end
end
end