require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Expectations
    describe TimesCalledExpectation do
      context "when using a ProcMatcher" do
        include_examples "RR::Expectations::TimesCalledExpectation"

        before do
          stub(subject).foobar.times(lambda {|value| value == 2})
        end

        describe "#verify" do
          it "passes after attempt! called 2 times" do
            subject.foobar
            subject.foobar
            RR.verify
          end

          it "fails after attempt! called 1 time" do
            subject.foobar
            expect { RR.verify }.to raise_error(RR::Errors::TimesCalledError)
          end

          it "fails after attempt! called 3 times" do
            subject.foobar
            subject.foobar
            subject.foobar
            expect { RR.verify }.to raise_error(RR::Errors::TimesCalledError)
          end
        end
      end
    end
  end
end
