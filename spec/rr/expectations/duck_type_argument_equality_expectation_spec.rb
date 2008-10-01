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

        it "returns true when passed in an DuckType matcher with the same argument list" do
          expectation.should be_exact_match(WildcardMatchers::DuckType.new(:to_s))
        end

        it "returns false when passed in an DuckType matcher with a different argument list" do
          expectation.should_not be_exact_match(WildcardMatchers::DuckType.new(:to_s, :to_i))
        end

        it "returns false otherwise" do
          expectation.should_not be_exact_match("hello")
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

          @expectation = ArgumentEqualityExpectation.new(duck_type(:quack, :waddle))
        end

        it "returns true when object matches all required methods" do
          expectation.should be_wildcard_match(@matching_object)
        end

        it "returns false when object matches some required methods" do
          expectation.should_not be_wildcard_match(@partial_matching_object)
        end

        it "returns false when passed an object that matches no required methods" do
          expectation.should_not be_wildcard_match(@not_match_object)
        end

        it "returns true when an exact match" do
          expectation.should be_wildcard_match(duck_type(:quack, :waddle))
        end

        it "returns false when not passed correct number of arguments" do
          expectation.should_not be_wildcard_match()
          expectation.should_not be_wildcard_match(@matching_object, @matching_object)
        end
      end
    end
  end
end
end
