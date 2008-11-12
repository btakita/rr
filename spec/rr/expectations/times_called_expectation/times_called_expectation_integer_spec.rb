require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Expectations
    describe TimesCalledExpectation do
      context "when using an IntegerMatcher" do
        it_should_behave_like "RR::Expectations::TimesCalledExpectation"
        attr_reader :matcher, :expected_line, :expectation

        before do
          double.definition.times(2)
          @matcher = double.definition.times_matcher
          @expectation = TimesCalledExpectation.new(double)
        end

        describe "#verify" do
          it "returns true when times called exactly matches an integer" do
            expectation.verify.should == false
            expectation.attempt
            expectation.verify.should == false
            expectation.attempt
            expectation.verify.should == true
          end
        end

        describe "#verify! when passed an Integer (2)" do
          it "passes after attempt! called 2 times" do
            expectation.attempt
            expectation.attempt
            expectation.verify!
          end

          it "fails after attempt! called 1 time" do
            expectation.attempt
            lambda {expectation.verify!}.should raise_error(
            Errors::TimesCalledError,
            "foobar()\nCalled 1 time.\nExpected 2 times."
            )
          end

          it "can't be called when attempt! is called 3 times" do
            expectation.attempt
            expectation.attempt
            lambda do
              expectation.attempt
            end.should raise_error(Errors::TimesCalledError, "foobar()\nCalled 3 times.\nExpected 2 times.")
          end

          it "has a backtrace to where the TimesCalledExpectation was instantiated on failure" do
            error = nil
            begin
              expectation.verify!
            rescue Errors::TimesCalledError => e
              error = e
            end
            e.backtrace.first.should include(__FILE__)
            e.backtrace.first.should include(":#{expected_line}")
          end

          it "has an error message that includes the number of times called and expected number of times" do
            lambda do
              expectation.verify!
            end.should raise_error(Errors::TimesCalledError, "foobar()\nCalled 0 times.\nExpected 2 times.")
          end
        end

        describe "#attempt?" do
          it "returns true when attempted less than expected times" do
            1.times {expectation.attempt}
            expectation.should be_attempt
          end

          it "returns false when attempted expected times" do
            2.times {expectation.attempt}
            expectation.should_not be_attempt
          end

          it "raises error before attempted more than expected times" do
            2.times {expectation.attempt}
            lambda {expectation.attempt}.should raise_error(
            Errors::TimesCalledError
            )
          end
        end

        describe "#attempt! for an IntegerMatcher" do
          it "raises error when attempt! called more than the expected number of times" do
            expectation.attempt
            expectation.attempt
            lambda do
              expectation.attempt
            end.should raise_error(Errors::TimesCalledError)
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