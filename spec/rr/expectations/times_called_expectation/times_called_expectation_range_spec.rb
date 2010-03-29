require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Expectations
    describe TimesCalledExpectation do
      context "when using a RangeMatcher" do
        it_should_behave_like "RR::Expectations::TimesCalledExpectation"

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
            lambda do
              subject.foobar
            end.should raise_error(RR::Errors::TimesCalledError, "foobar()\nCalled 3 times.\nExpected 1..2 times.")
            lambda do
              RR.verify
            end.should raise_error(RR::Errors::TimesCalledError, "foobar()\nCalled 3 times.\nExpected 1..2 times.")
          end
        end
      end
    end
  end
end