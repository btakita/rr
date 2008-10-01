require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Expectations
    describe ArgumentEqualityExpectation do
      context "with a boolean matcher" do
        attr_reader :expectation

        before do
          @expectation = ArgumentEqualityExpectation.new(boolean)
        end

        describe "#exact_match?" do
          context "when passed a Boolean matcher" do
            it "returns true" do
              expectation.should be_exact_match(WildcardMatchers::Boolean.new)
            end            
          end

          context "when not passed a Boolean matcher" do
            it "returns false" do
              expectation.should_not be_exact_match("hello")
              expectation.should_not be_exact_match(:hello)
              expectation.should_not be_exact_match(1)
              expectation.should_not be_exact_match(nil)
              expectation.should_not be_exact_match(true)
              expectation.should_not be_exact_match()
            end
          end
        end

        describe "#wildcard_match?" do
          before do
            expectation = ArgumentEqualityExpectation.new(boolean)
          end

          context "when passed a Boolean" do
            it "returns true" do
              expectation.should be_wildcard_match(true)
              expectation.should be_wildcard_match(false)
            end
          end

          context "when not passed a Boolean" do
            it "returns false" do
              expectation.should_not be_wildcard_match(:not_a_boolean)
            end
          end

          context "when an exact match" do
            it "returns true" do
              expectation.should be_wildcard_match(boolean)
            end
          end

          context "when not passed correct number of arguments" do
            it "returns false" do
              expectation.should_not be_wildcard_match()
              expectation.should_not be_wildcard_match(true, false)
            end
          end
        end
      end
    end
  end
end
