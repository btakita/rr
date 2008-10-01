require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Expectations
    describe ArgumentEqualityExpectation do
      context "with Regexp matcher" do
        attr_reader :expectation

        before do
          @expectation = ArgumentEqualityExpectation.new(/abc/)
        end

        describe "#exact_match?" do
          context "when passed a Regexp matcher with the same argument list" do
            it "returns true" do
              expectation.should be_exact_match(/abc/)
            end
          end

          context "when passed a Regexp matcher with a different argument list" do
            it "returns false" do
              expectation.should_not be_exact_match(/def/)
            end
          end
        end

        context "when not passed a Regexp matcher" do
          it "returns false" do
            expectation.should_not be_exact_match("abc")
            expectation.should_not be_exact_match(:hello)
            expectation.should_not be_exact_match(1)
            expectation.should_not be_exact_match(nil)
            expectation.should_not be_exact_match(true)
            expectation.should_not be_exact_match()
          end
        end

        describe "#wildcard_match?" do
          before do
            @matching_object = Object.new
            def @matching_object.quack
            end
            def @matching_object.waddle
            end

            @partial_matching_object = Object.new
            def @partial_matching_object.quack
            end

            @not_match_object = Object.new

            expectation = ArgumentEqualityExpectation.new(/abc/)
          end

          context "when passed-in String matches the Regexp" do
            it "returns true" do
              expectation.should be_wildcard_match("Tabcola")
            end
          end

          context "when passed-in String does not match the Regexp" do
            it "returns false" do
              expectation.should_not be_wildcard_match("no match here")
            end
          end
        end
      end
    end
  end
end
