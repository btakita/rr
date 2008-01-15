require "spec/spec_helper"

module RR
  module WildcardMatchers
    describe DuckType do
      describe "#inspect" do
        it "returns duck_type with methods" do
          matcher = DuckType.new(:foo, :bar, :baz)
          matcher.inspect.should == "duck_type(:foo, :bar, :baz)"
        end
      end
    end
  end
end