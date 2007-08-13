require "examples/example_helper"

module RR
module Expectations
  describe TimesCalledExpectation, " with IntegerMatcher", :shared => true do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation"

    before do
      @matcher = TimesCalledMatchers::IntegerMatcher.new(2)
      @expectation = TimesCalledExpectation.new(@scenario, @matcher)
      @expected_line = __LINE__ - 1
    end
  end

  describe TimesCalledExpectation, "#verify" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with IntegerMatcher"

    it "returns true when times called exactly matches an integer" do
      @expectation.verify.should == false
      @expectation.attempt!
      @expectation.verify.should == false
      @expectation.attempt!
      @expectation.verify.should == true
    end
  end
  
  describe TimesCalledExpectation, "#verify! when passed an Integer (2)" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with IntegerMatcher"

    it "passes after attempt! called 2 times" do
      @expectation.attempt!
      @expectation.attempt!
      @expectation.verify!
    end

    it "fails after attempt! called 1 time" do
      @expectation.attempt!
      proc {@expectation.verify!}.should raise_error(
        Errors::TimesCalledError,
        "foobar()\nCalled 1 time.\nExpected 2 times."
      )
    end

    it "can't be called when attempt! is called 3 times" do
      @expectation.attempt!
      @expectation.attempt!
      proc do
        @expectation.attempt!
      end.should raise_error(Errors::TimesCalledError, "foobar()\nCalled 3 times.\nExpected 2 times.")
    end

    it "has a backtrace to where the TimesCalledExpectation was instantiated on failure" do
      error = nil
      begin
        @expectation.verify!
      rescue Errors::TimesCalledError => e
        error = e
      end
      e.backtrace.first.should include(__FILE__)
      e.backtrace.first.should include(":#{@expected_line}")
    end

    it "has an error message that includes the number of times called and expected number of times" do
      proc do
        @expectation.verify!
      end.should raise_error(Errors::TimesCalledError, "foobar()\nCalled 0 times.\nExpected 2 times.")
    end
  end

  describe TimesCalledExpectation, "#attempt? with IntegerMatcher" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with IntegerMatcher"

    it "returns true when attempted less than expected times" do
      1.times {@expectation.attempt!}
      @expectation.should be_attempt
    end

    it "returns false when attempted expected times" do
      2.times {@expectation.attempt!}
      @expectation.should_not be_attempt
    end

    it "raises error before attempted more than expected times" do
      2.times {@expectation.attempt!}
      proc {@expectation.attempt!}.should raise_error(
        Errors::TimesCalledError
      )
    end
  end

  describe TimesCalledExpectation, "#attempt! for an IntegerMatcher" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with IntegerMatcher"

    it "raises error when attempt! called more than the expected number of times" do
      @expectation.attempt!
      @expectation.attempt!
      proc do
        @expectation.attempt!
      end.should raise_error(Errors::TimesCalledError)
    end
  end

  describe TimesCalledExpectation, "#terminal? with IntegerMatcher" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation with IntegerMatcher"

    it "returns true" do
      @expectation.should be_terminal
    end
  end
end
end