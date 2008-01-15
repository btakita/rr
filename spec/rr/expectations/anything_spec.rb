require "spec/spec_helper"

module RR
  module WildcardMatchers
    describe Anything do
      describe "#inspect" do
        it "returns anything" do
          matcher = Anything.new
          matcher.inspect.should == "anything"
        end
      end
    end
  end
end