require "spec/spec_helper"

module RR
  module WildcardMatchers
    describe Numeric do
      describe "#inspect" do
        it "returns numeric" do
          matcher = Numeric.new
          matcher.inspect.should == "numeric"
        end
      end
    end
  end
end