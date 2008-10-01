require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Expectations
    describe ArgumentEqualityExpectation do
      context "when matching anything" do
        attr_reader :expectation
        before do
          @expectation = ArgumentEqualityExpectation.new(anything)
        end

        describe "#exact_match?" do
          context "with anything argument" do
            context "when passed an Anything matcher" do
              it "returns true" do
                expectation.should be_exact_match(WildcardMatchers::Anything.new)
              end
            end

            context "when not passed an Anything matcher" do
              it "returns false" do
                expectation.should_not be_exact_match("hello")
                expectation.should_not be_exact_match(:hello)
                expectation.should_not be_exact_match(1)
                expectation.should_not be_exact_match(nil)
                expectation.should_not be_exact_match()
              end
            end
          end
        end
      end
    end
  end
end
