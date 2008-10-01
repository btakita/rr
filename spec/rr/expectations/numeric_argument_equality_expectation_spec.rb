require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Expectations
    describe ArgumentEqualityExpectation do
      context "with numeric matcher" do
        attr_reader :expectation

        before do
          @expectation = ArgumentEqualityExpectation.new(numeric)
        end

        describe "#exact_match?" do
          context "when passed a Numeric matcher" do
            it "returns true" do
              expectation.should be_exact_match(WildcardMatchers::Numeric.new)
            end
          end

          context "when not passed a Numeric matcher" do
            it "returns false" do
              expectation.should_not be_exact_match("hello")
              expectation.should_not be_exact_match(:hello)
              expectation.should_not be_exact_match(1)
              expectation.should_not be_exact_match(nil)
              expectation.should_not be_exact_match()
            end
          end
        end

        describe "#wildcard_match?" do
          context "when passed a Numeric" do
            it "returns true" do
              expectation.should be_wildcard_match(99)
            end
          end

          context "when not passed a Numeric" do
            it "returns false" do
              expectation.should_not be_wildcard_match(:not_a_numeric)
            end
          end
        end
      end
    end
  end
end
