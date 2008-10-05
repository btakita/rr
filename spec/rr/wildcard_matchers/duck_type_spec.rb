require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module WildcardMatchers
    describe DuckType do
      attr_reader :matcher
      before do
        @matcher = DuckType.new(:quack, :waddle)
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
        end

        context "when passed-in object matches all required methods" do
          it "returns true" do
            matcher.should be_wildcard_match(@matching_object)
          end
        end

        context "when passed-in object matches some required methods" do
          it "returns false" do
            matcher.should_not be_wildcard_match(@partial_matching_object)
          end
        end

        context "when passed-in object matches no required methods" do
          it "returns false" do
            matcher.should_not be_wildcard_match(@not_match_object)
          end
        end
      end

      describe "#inspect" do
        it "returns duck_type with methods" do
          matcher.inspect.should == "duck_type(:quack, :waddle)"
        end
      end
    end
  end
end