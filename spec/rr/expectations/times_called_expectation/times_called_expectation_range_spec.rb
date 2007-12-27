require "spec/example_helper"

module RR
module Expectations
  describe TimesCalledExpectation, " with RangeMatcher", :shared => true do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation"

    before do
      @matcher = TimesCalledMatchers::RangeMatcher.new(1..2)
      @expectation = TimesCalledExpectation.new(@scenario, @matcher)
      @expected_line = __LINE__ - 1
    end
  end

  describe TimesCalledExpectation, "#verify" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with RangeMatcher"

    it "returns true when times called falls within a range" do
      @expectation.verify.should == false
      @expectation.attempt!
      @expectation.verify.should == true
      @expectation.attempt!
      @expectation.verify.should == true
    end
  end
  
  describe TimesCalledExpectation, "#verify! when passed a Range (1..2)" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with RangeMatcher"

    it "passes after attempt! called 1 time" do
      @expectation.attempt!
      @expectation.verify!
    end

    it "passes after attempt! called 2 times" do
      @expectation.attempt!
      @expectation.attempt!
      @expectation.verify!
    end

    it "can't be called when attempt! is called 3 times" do
      @expectation.attempt!
      @expectation.attempt!
      proc do
        @expectation.attempt!
      end.should raise_error(Errors::TimesCalledError, "foobar()\nCalled 3 times.\nExpected 1..2 times.")
    end
  end

  describe TimesCalledExpectation, "#attempt? with RangeMatcher" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with RangeMatcher"

    it "returns true when attempted less than low end of range" do
      @expectation.should be_attempt
    end

    it "returns false when attempted in range" do
      @expectation.attempt!
      @expectation.should be_attempt
      @expectation.attempt!
      @expectation.should be_attempt
    end

    it "raises error before attempted more than expected times" do
      2.times {@expectation.attempt!}
      proc {@expectation.attempt!}.should raise_error(
        Errors::TimesCalledError
      )
    end
  end

  describe TimesCalledExpectation, "#attempt! for a range expectation" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with RangeMatcher"

    it "raises error when attempt! called more than range permits" do
      @expectation.attempt!
      @expectation.attempt!
      raises_expectation_error {@expectation.attempt!}
    end
  end

  describe TimesCalledExpectation, "#terminal? with RangeMatcher" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with RangeMatcher"

    it "returns true" do
      @expectation.should be_terminal
    end
  end
end
end