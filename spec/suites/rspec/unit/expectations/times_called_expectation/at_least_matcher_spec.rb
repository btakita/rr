require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Expectations
    describe TimesCalledExpectation do
      context "when using an AtLeastMatcher" do
        include_examples "RR::Expectations::TimesCalledExpectation"

        before do
          mock(subject).foobar.at_least(3)
        end

        describe "#verify!" do
          it "passes when times called > times" do
            4.times {subject.foobar}
            RR.verify
          end

          it "passes when times called == times" do
            3.times {subject.foobar}
            RR.verify
          end

          it "raises error when times called < times" do
            subject.foobar
            expect {
              RR.verify
            }.to raise_error(
              RR::Errors::TimesCalledError,
              "foobar()\nCalled 1 time.\nExpected at least 3 times."
            )
          end
        end
      end
    end
  end
end
