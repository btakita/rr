require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module WildcardMatchers
    describe IsA do
      attr_reader :matcher
      before do
        @matcher = IsA.new(Symbol)
      end

      describe "#wildcard_match?" do
        context "when passed an instance of the expected Module" do
          it "returns true" do
            matcher.should be_wildcard_match(:a_symbol)
          end
        end

        context "when not passed an instance of the expected Module" do
          it "returns false" do
            matcher.should_not be_wildcard_match("not a symbol")
          end
        end
      end

      describe "#inspect" do
        it "returns the is_a(ClassName)" do
          matcher.inspect.should == "is_a(Symbol)"
        end
      end
    end
  end
end