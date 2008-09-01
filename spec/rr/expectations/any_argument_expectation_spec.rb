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
          expectation.expected_arguments.should == []
        end
      end

      describe "==" do
        it "returns true when comparing with another AnyArgumentExpectation" do
          expectation.should == AnyArgumentExpectation.new
        end

        it "returns false when comparing with ArgumentEqualityExpectation" do
          expectation.should_not == ArgumentEqualityExpectation.new(1)
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
          expectation.should be_wildcard_match(1, 2, 3)
          expectation.should be_wildcard_match("whatever")
          expectation.should be_wildcard_match("whatever", "else")
        end
      end
    end
  end
end
