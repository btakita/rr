require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module WildcardMatchers
    describe Boolean do
      attr_reader :matcher

      before do
        @matcher = Boolean.new
      end

      describe "#wildcard_match?" do
        context "when passed a Boolean" do
          it "returns true" do
            expect(matcher).to be_wildcard_match(true)
            expect(matcher).to be_wildcard_match(false)
          end
        end

        context "when not passed a Boolean" do
          it "returns false" do
            matcher.should_not be_wildcard_match(:not_a_boolean)
          end
        end
      end

      describe Boolean do
        describe "#inspect" do
          it "returns boolean" do
            expect(matcher.inspect).to eq "boolean"
          end
        end
      end
    end
  end
end
