require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module WildcardMatchers
    describe IsA do
      describe "#inspect" do
        it "returns the is_a(ClassName)" do
          matcher = IsA.new(Symbol)
          matcher.inspect.should == "is_a(Symbol)"
        end
      end
    end
  end
end