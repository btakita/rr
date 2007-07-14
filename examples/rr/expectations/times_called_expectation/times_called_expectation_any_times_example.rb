require "examples/example_helper"

module RR
module Expectations
  describe TimesCalledExpectation, ' with AnyTimesMatcher', :shared => true do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation"
    
    before do
      @at_least = TimesCalledMatchers::AnyTimesMatcher.new
      @expectation = TimesCalledExpectation.new(@at_least)
    end
  end

  describe TimesCalledExpectation, "#verify! with AnyTimesMatcher" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with AnyTimesMatcher"

    it "always passes" do
      @expectation.verify!
      10.times {@expectation.attempt!}
      @expectation.verify!
    end
  end

  describe TimesCalledExpectation, "#attempt? with AnyTimesMatcher" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with AnyTimesMatcher"

    it "always returns true" do
      @expectation.should be_attempt
      10.times {@expectation.attempt!}
      @expectation.should be_attempt
    end
  end

  describe TimesCalledExpectation, "#attempt! with AnyTimesMatcher" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with AnyTimesMatcher"
    
    it "always passes" do
      10.times {@expectation.attempt!}
    end
  end
end
end