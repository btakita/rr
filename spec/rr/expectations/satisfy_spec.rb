require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module WildcardMatchers
    describe Satisfy do
      describe "#inspect" do
        it "returns satisfy string" do
          matcher = Satisfy.new(lambda {})
          expect(matcher.inspect).to eq "satisfy {block}"
        end
      end
    end
  end
end
