require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Expectations
    describe ArgumentEqualityExpectation do
      context "with a DuckType argument" do
        attr_reader :expectation

        describe "#exact_match?" do
          before do
            @expectation = ArgumentEqualityExpectation.new(duck_type(:to_s))
          end

          context "when passed a DuckType matcher with the same argument list" do
            it "returns true" do
              expectation.should be_exact_match(WildcardMatchers::DuckType.new(:to_s))
            end
          end

          context "when passed a DuckType matcher with a different argument list" do
            it "returns false" do
              expectation.should_not be_exact_match(WildcardMatchers::DuckType.new(:to_s, :to_i))
            end
          end

          context "when not passed a DuckType matcher" do
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
            @matching_object = Object.new
            def @matching_object.quack
            end
            def @matching_object.waddle
            end

            @partial_matching_object = Object.new
            def @partial_matching_object.quack
            end

            @not_match_object = Object.new

            @expectation = ArgumentEqualityExpectation.new(duck_type(:quack, :waddle))
          end

          context "when passed-in object matches all required methods" do
            it "returns true" do
              expectation.should be_wildcard_match(@matching_object)
            end
          end


          context "when passed-in object matches some required methods" do
            it "returns false" do
              expectation.should_not be_wildcard_match(@partial_matching_object)
            end
          end

          context "when passed-in object matches no required methods" do
            it "returns false" do
              expectation.should_not be_wildcard_match(@not_match_object)
            end
          end

          context "when passed-in object is an exact match" do
            it "returns true" do
              expectation.should be_wildcard_match(duck_type(:quack, :waddle))
            end
          end

          context "when not passed in the correct number of arguments" do
            it "returns false" do
              expectation.should_not be_wildcard_match()
              expectation.should_not be_wildcard_match(@matching_object, @matching_object)
            end
          end
        end
      end
    end
  end
end
