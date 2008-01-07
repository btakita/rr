require "spec/spec_helper"

module RR
  module Expectations
    describe TimesCalledExpectation, " with ProcMatcher" do
      it_should_behave_like "RR::Expectations::TimesCalledExpectation"
      attr_reader :matcher

      before do
        @matcher = TimesCalledMatchers::ProcMatcher.new(proc {|value| value == 2})
        @expectation = TimesCalledExpectation.new(double, matcher)
      end
      
      describe "#verify" do
        it "matches a block" do
          expectation.verify.should == false
          expectation.attempt!
          expectation.verify.should == false
          expectation.attempt!
          expectation.verify.should == true
          expectation.attempt!
          expectation.verify.should == false
        end
      end

      describe "#verify! when passed a block (== 2 times)" do
        it "passes after attempt! called 2 times" do
          expectation.attempt!
          expectation.attempt!
          expectation.verify!
        end

        it "fails after attempt! called 1 time" do
          expectation.attempt!
          proc {expectation.verify!}.should raise_error(Errors::TimesCalledError)
        end

        it "fails after attempt! called 3 times" do
          expectation.attempt!
          expectation.attempt!
          expectation.attempt!
          proc {expectation.verify!}.should raise_error(Errors::TimesCalledError)
        end
      end

      describe "#attempt? with IntegerMatcher" do
        it "returns true when attempted less than expected times" do
          1.times {expectation.attempt!}
          expectation.should be_attempt
        end

        it "returns true when attempted expected times" do
          2.times {expectation.attempt!}
          expectation.should be_attempt
        end

        it "returns true when attempted more than expected times" do
          3.times {expectation.attempt!}
          expectation.should be_attempt
        end
      end

      describe "#attempt! for a proc expectation" do
        it "lets everything pass" do
          @object.foobar
          @object.foobar
          @object.foobar
        end
      end

      describe "#terminal? with ProcMatcher" do
        it "returns false" do
          expectation.should_not be_terminal
        end
      end
    end

  end
end