require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Expectations
    describe ArgumentEqualityExpectation do
      context "with a boolean matcher" do
        attr_reader :expectation

        before do
          @expectation = ArgumentEqualityExpectation.new(boolean)
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
        end
      end
    end
  end
end
