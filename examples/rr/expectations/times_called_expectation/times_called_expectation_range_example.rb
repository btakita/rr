require "examples/example_helper"

module RR
module Expectations
  describe TimesCalledExpectation, "#verify" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation"

    it "returns true when times called falls within a range" do
      @expectation = TimesCalledExpectation.new(1..2)

      @expectation.verify.should == false
      @expectation.attempt!
      @expectation.verify.should == true
      @expectation.attempt!
      @expectation.verify.should == true
    end
  end
  
  describe TimesCalledExpectation, "#verify! when passed a Range (1..2)" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation"

    before do
      @expectation = TimesCalledExpectation.new(1..2)
    end

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
      end.should raise_error(Errors::TimesCalledError, "Called 3 times. Expected 1..2.")
    end
  end

  describe TimesCalledExpectation, "#attempt! for a range expectation" do
    it_should_behave_like "RR::Expectations::TimesCalledExpectation"

    it "raises error when attempt! called more than range permits" do
      @expectation = TimesCalledExpectation.new(1..2)
      @expectation.attempt!
      @expectation.attempt!
      raises_expectation_error {@expectation.attempt!}
    end
  end  
end
end