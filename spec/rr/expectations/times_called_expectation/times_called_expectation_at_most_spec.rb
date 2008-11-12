require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Expectations
    describe TimesCalledExpectation do
      context "when using an AtMostMatcher" do
        it_should_behave_like "RR::Expectations::TimesCalledExpectation"
        attr_reader :times, :at_most, :expectation

        before do
          @times = 3
          double.definition.at_most(times)
          @at_most = double.definition.times_matcher
          @expectation = TimesCalledExpectation.new(double)
        end

        describe "#verify!" do
          it "returns true when times called == times" do
            3.times {expectation.attempt}
            expectation.verify!
          end

          it "raises error when times called < times" do
            2.times {expectation.attempt}
            expectation.verify!
          end
        end

        describe "#attempt?" do
          it "returns true when attempted less than expected times" do
            2.times {expectation.attempt}
            expectation.should be_attempt
          end

          it "returns false when attempted expected times" do
            3.times {expectation.attempt}
            expectation.should_not be_attempt
          end

          it "raises error before attempted more than expected times" do
            3.times {expectation.attempt}
            lambda {expectation.attempt}.should raise_error( Errors::TimesCalledError )
          end
        end

        describe "#attempt!" do
          it "fails when times called more than times" do
            3.times {expectation.attempt}
            lambda do
              expectation.attempt
            end.should raise_error(Errors::TimesCalledError, "foobar()\nCalled 4 times.\nExpected at most 3 times.")
          end

          it "passes when times called == times" do
            3.times {expectation.attempt}
          end

          it "passes when times called < times" do
            expectation.attempt
          end
        end

        describe "#terminal?" do
          it "returns true" do
            expectation.should be_terminal
          end
        end
      end
    end
  end
end
