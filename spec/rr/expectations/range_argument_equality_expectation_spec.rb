require "spec/spec_helper"

module RR
  module Expectations
    describe ArgumentEqualityExpectation, "with range argument" do
      attr_reader :expectation
      before do
        @expectation = ArgumentEqualityExpectation.new(2..5)
      end

      describe "#exact_match?" do
        it "returns true when passed in an Range matcher with the same argument list" do
          expectation.should be_exact_match(2..5)
        end

        it "returns false when passed in an Range matcher with a different argument list" do
          expectation.should_not be_exact_match(3..6)
        end

        it "returns false otherwise" do
          expectation.should_not be_exact_match(2)
          expectation.should_not be_exact_match(:hello)
          expectation.should_not be_exact_match(3)
          expectation.should_not be_exact_match(nil)
          expectation.should_not be_exact_match(true)
          expectation.should_not be_exact_match()
        end
      end

      describe "#wildcard_match?" do
        it "returns true when string matches the range" do
          expectation.should be_wildcard_match(3)
        end

        it "returns false when string does not match the range" do
          expectation.should_not be_wildcard_match(7)
        end

        it "returns true when an exact match" do
          expectation.should be_wildcard_match(2..5)
        end

        it "returns false when not an exact match" do
          expectation.should_not be_wildcard_match(3..9)
        end

        it "returns false when not a number" do
          expectation.should_not be_wildcard_match("Not a number")
        end

        it "returns false when not passed correct number of arguments" do
          expectation.should_not be_wildcard_match()
          expectation.should_not be_wildcard_match(2, 3)
        end
      end
    end

  end
end
