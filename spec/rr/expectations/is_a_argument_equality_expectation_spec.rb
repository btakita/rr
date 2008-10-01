require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Expectations
    describe ArgumentEqualityExpectation do
      context "with is_a String matcher" do
        attr_reader :expectation

        before do
          @expectation = ArgumentEqualityExpectation.new(is_a(String))
        end

        describe "#exact_match?" do
          context "when passed an IsA matcher with the same Module argument" do
            it "returns true" do
              expectation.should be_exact_match(WildcardMatchers::IsA.new(String))
            end
          end

          context "when passed an IsA matcher with a different module" do
            it "returns false" do
              expectation.should_not be_exact_match(WildcardMatchers::IsA.new(Integer))
            end
          end

          context "when not passed an IsA matcher" do
            it "returns false otherwise" do
              expectation.should_not be_exact_match("hello")
              expectation.should_not be_exact_match(:hello)
              expectation.should_not be_exact_match(1)
              expectation.should_not be_exact_match(nil)
              expectation.should_not be_exact_match()
            end
          end
        end

        describe "#wildcard_match?" do
          context "when passed an instance of the expected Module" do
            it "returns true" do
              expectation.should be_wildcard_match("Hello")
            end
          end

          context "when not passed an instance of the expected Module" do
            it "returns false" do
              expectation.should_not be_wildcard_match(:not_a_string)
            end
          end
        end
      end
    end
  end
end
