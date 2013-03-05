require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module WildcardMatchers
    describe Anything do
      attr_reader :matcher
      before do
        @matcher = Anything.new
      end

      describe "#wildcard_match?" do
        it "returns true" do
          expect(matcher).to be_wildcard_match(Object.new)
        end
      end

      describe "#inspect" do
        it "returns anything" do
          expect(matcher.inspect).to eq "anything"
        end
      end
    end
  end
end
