require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Expectations
    describe TimesCalledExpectation do
      context "when using an AtMostMatcher" do
        include_examples "RR::Expectations::TimesCalledExpectation"

        before do
          stub(subject).foobar.at_most(3)
        end

        describe "#verify!" do
          it "passes when times called == times" do
            3.times {subject.foobar}
            RR.verify
          end

          it "passes when times called < times" do
            2.times {subject.foobar}
            RR.verify
          end

          it "raises error when times called > times" do
            expect {
              4.times {subject.foobar}
            }.to raise_error(
              RR::Errors::TimesCalledError,
              "foobar()\nCalled 4 times.\nExpected at most 3 times."
            )

            expect {
              RR.verify
            }.to raise_error(
              RR::Errors::TimesCalledError,
              "foobar()\nCalled 4 times.\nExpected at most 3 times."
            )
          end
        end
      end
    end
  end
end
