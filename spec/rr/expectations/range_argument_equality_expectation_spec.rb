require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Expectations
    describe ArgumentEqualityExpectation do
      context "with Range argument" do
        attr_reader :expectation
        before do
          @expectation = ArgumentEqualityExpectation.new(2..5)
        end

        describe "#exact_match?" do
          context "when passed a Range matcher with the same argument list" do
            it "returns true" do
              expectation.should be_exact_match(2..5)
            end
          end

          context "when passed a Range matcher with a different argument list" do
            it "returns false" do
              expectation.should_not be_exact_match(3..6)
            end
          end

          context "when not passed a Range matcher" do
            it "returns false" do
              expectation.should_not be_exact_match(2)
              expectation.should_not be_exact_match(:hello)
              expectation.should_not be_exact_match(3)
              expectation.should_not be_exact_match(nil)
              expectation.should_not be_exact_match(true)
              expectation.should_not be_exact_match()
            end
          end
        end

        describe "#wildcard_match?" do
          context "when passed-in number falls within the Range" do
            it "returns true" do
              expectation.should be_wildcard_match(3)
            end
          end

          context "when passed-in number does not fall within the Range" do
            it "returns false" do
              expectation.should_not be_wildcard_match(7)
            end
          end

          context "when passed-in argument is an exact match" do
            it "returns true" do
              expectation.should be_wildcard_match(2..5)
            end
          end

          context "when passed-in argument is not an exact match" do
            it "returns false" do
              expectation.should_not be_wildcard_match(3..9)
            end
          end

          context "when passed-in argument is not a number" do
            it "returns false" do
              expectation.should_not be_wildcard_match("Not a number")
            end
          end

          context "when not passed correct number of arguments" do
            it "returns false" do
              expectation.should_not be_wildcard_match()
              expectation.should_not be_wildcard_match(2, 3)
            end
          end
        end
      end
    end
  end
end
