require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module WildcardMatchers
    describe Numeric do
      attr_reader :matcher
      before do
        @matcher = Numeric.new
      end

      describe "#wildcard_match?" do
        context "when passed a Numeric" do
          it "returns true" do
            matcher.should be_wildcard_match(99)
          end
        end

        context "when not passed a Numeric" do
          it "returns false" do
            matcher.should_not be_wildcard_match(:not_a_numeric)
          end
        end
      end

      describe "#inspect" do
        it "returns numeric" do
          matcher.inspect.should == "numeric"
        end
      end
    end
  end
end