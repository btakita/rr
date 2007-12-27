require "spec/spec_helper"

module RR
  module Expectations
    describe ArgumentEqualityExpectation, "with numeric argument" do
      attr_reader :expectation

      before do
        @expectation = ArgumentEqualityExpectation.new(numeric)
      end

      describe "#exact_match?" do
        it "returns true when passed in an IsA module" do
          expectation.should be_exact_match(WildcardMatchers::Numeric.new)
        end

        it "returns false otherwise" do
          expectation.should_not be_exact_match("hello")
          expectation.should_not be_exact_match(:hello)
          expectation.should_not be_exact_match(1)
          expectation.should_not be_exact_match(nil)
          expectation.should_not be_exact_match()
        end
      end

      describe "#wildcard_match?" do
        it "returns true when passed a Numeric" do
          expectation.should be_wildcard_match(99)
        end

        it "returns false when not passed a Numeric" do
          expectation.should_not be_wildcard_match(:not_a_numeric)
        end

        it "returns true when an exact match" do
          expectation.should be_wildcard_match(numeric)
        end

        it "returns false when not passed correct number of arguments" do
          expectation.should_not be_wildcard_match()
          expectation.should_not be_wildcard_match(1, 2)
        end
      end
    end

  end
end
