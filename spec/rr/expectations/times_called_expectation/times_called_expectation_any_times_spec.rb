require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Expectations
    describe TimesCalledExpectation do
      context "when using an AnyTimesMatcher" do
        it_should_behave_like "RR::Expectations::TimesCalledExpectation"
        attr_reader :at_least, :expectation

        before do
          @at_least = TimesCalledMatchers::AnyTimesMatcher.new
          @expectation = TimesCalledExpectation.new(double, at_least)
        end

        describe "#verify!" do
          it "always passes" do
            expectation.verify!
            10.times {expectation.attempt}
            expectation.verify!
          end
        end

        describe "#attempt?" do
          it "always returns true" do
            expectation.should be_attempt
            10.times {expectation.attempt}
            expectation.should be_attempt
          end
        end

        describe "#attempt!" do
          it "always passes" do
            10.times {expectation.attempt}
          end
        end

        describe "#terminal?" do
          it "returns false" do
            expectation.should_not be_terminal
          end
        end
      end
    end
  end
end