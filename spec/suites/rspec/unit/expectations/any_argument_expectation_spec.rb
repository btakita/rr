require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Expectations
    describe AnyArgumentExpectation do
      attr_reader :expectation

      before do
        @expectation = AnyArgumentExpectation.new
      end

      describe "#expected_arguments" do
        it "returns an empty array" do
          expect(expectation.expected_arguments).to eq []
        end
      end

      describe "==" do
        it "returns true when comparing with another AnyArgumentExpectation" do
          expect(expectation).to eq AnyArgumentExpectation.new
        end

        it "returns false when comparing with ArgumentEqualityExpectation" do
          expect(expectation).to_not eq ArgumentEqualityExpectation.new(1)
        end
      end

      describe "#exact_match?" do
        it "returns false" do
          expectation.should_not be_exact_match(1, 2, 3)
          expectation.should_not be_exact_match(1, 2)
          expectation.should_not be_exact_match(1)
          expectation.should_not be_exact_match()
          expectation.should_not be_exact_match("does not match")
        end
      end

      describe "#wildcard_match?" do
        it "returns true" do
          expectation = AnyArgumentExpectation.new
          expect(expectation).to be_wildcard_match(1, 2, 3)
          expect(expectation).to be_wildcard_match("whatever")
          expect(expectation).to be_wildcard_match("whatever", "else")
        end
      end
    end
  end
end
