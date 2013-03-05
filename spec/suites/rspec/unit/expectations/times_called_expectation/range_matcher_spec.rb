require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Expectations
    describe TimesCalledExpectation do
      context "when using a RangeMatcher" do
        include_examples "RR::Expectations::TimesCalledExpectation"

        before do
          stub(subject).foobar.times(1..2)
        end

        describe "#verify" do
          it "passes after attempt! called 1 time" do
            subject.foobar
            RR.verify
          end

          it "passes after attempt! called 2 times" do
            subject.foobar
            subject.foobar
            RR.verify
          end

          it "can't be called when attempt! is called 3 times" do
            subject.foobar
            subject.foobar
            expect {
              subject.foobar
            }.to raise_error(RR::Errors::TimesCalledError, "foobar()\nCalled 3 times.\nExpected 1..2 times.")
            expect {
              RR.verify
            }.to raise_error(RR::Errors::TimesCalledError, "foobar()\nCalled 3 times.\nExpected 1..2 times.")
          end
        end
      end
    end
  end
end
