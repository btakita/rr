require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Expectations
    describe TimesCalledExpectation do
      context "when using an IntegerMatcher" do
        include_examples "RR::Expectations::TimesCalledExpectation"

        before do
          stub(subject).foobar.times(2)
        end

        describe "verify" do
          it "passes after attempt! called 2 times" do
            subject.foobar
            subject.foobar
            RR.verify
          end

          it "fails after attempt! called 1 time" do
            subject.foobar
            expect { RR.verify }.to raise_error(
              RR::Errors::TimesCalledError,
              "foobar()\nCalled 1 time.\nExpected 2 times."
            )
          end

          it "can't be called when attempt! is called 3 times" do
            subject.foobar
            subject.foobar
            expect {
              subject.foobar
            }.to raise_error(RR::Errors::TimesCalledError, "foobar()\nCalled 3 times.\nExpected 2 times.")
            expect {
              RR.verify
            }.to raise_error(RR::Errors::TimesCalledError, "foobar()\nCalled 3 times.\nExpected 2 times.")
          end

          it "has a backtrace to where the TimesCalledExpectation was instantiated on failure" do
            error = nil
            begin
              RR.verify
            rescue RR::Errors::TimesCalledError => e
              error = e
            end
            expect(e.backtrace.join("\n")).to include(__FILE__)
          end

          it "has an error message that includes the number of times called and expected number of times" do
            expect {
              RR.verify
            }.to raise_error(RR::Errors::TimesCalledError, "foobar()\nCalled 0 times.\nExpected 2 times.")
          end
        end
      end
    end
  end
end
