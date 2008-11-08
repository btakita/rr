require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Expectations
    describe TimesCalledExpectation do
      context "when using a RangeMatcher" do
        it_should_behave_like "RR::Expectations::TimesCalledExpectation"
        attr_reader :matcher, :expectation

        before do
          double.definition.times(1..2)
          @matcher = double.definition.times_matcher
          @expectation = TimesCalledExpectation.new(double)
        end

        describe "#verify" do
          it "returns true when times called falls within a range" do
            expectation.verify.should == false
            expectation.attempt
            expectation.verify.should == true
            expectation.attempt
            expectation.verify.should == true
          end
        end

        describe "#verify! when passed a Range (1..2)" do
          it "passes after attempt! called 1 time" do
            expectation.attempt
            expectation.verify!
          end

          it "passes after attempt! called 2 times" do
            expectation.attempt
            expectation.attempt
            expectation.verify!
          end

          it "can't be called when attempt! is called 3 times" do
            expectation.attempt
            expectation.attempt
            lambda do
              expectation.attempt
            end.should raise_error(Errors::TimesCalledError, "foobar()\nCalled 3 times.\nExpected 1..2 times.")
          end
        end

        describe "#attempt? with RangeMatcher" do
          it "returns true when attempted less than low end of range" do
            expectation.should be_attempt
          end

          it "returns false when attempted in range" do
            expectation.attempt
            expectation.should be_attempt
            expectation.attempt
            expectation.should be_attempt
          end

          it "raises error before attempted more than expected times" do
            2.times {expectation.attempt}
            lambda {expectation.attempt}.should raise_error(
            Errors::TimesCalledError
            )
          end
        end

        describe "#attempt! for a range expectation" do
          it "raises error when attempt! called more than range permits" do
            expectation.attempt
            expectation.attempt
            raises_expectation_error {expectation.attempt}
          end
        end

        describe "#terminal? with RangeMatcher" do
          it "returns true" do
            expectation.should be_terminal
          end
        end
      end
    end
  end
end