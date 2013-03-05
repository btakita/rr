require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module WildcardMatchers
    describe HashIncluding do
      describe "#inspect" do
        it "returns hash_including with expected key/values" do
          expected_hash = {:foo => "bar", :baz => "qux"}
          matcher = HashIncluding.new(expected_hash)
          expect(matcher.inspect).to include("hash_including(")
          expect(matcher.inspect).to include(':foo=>"bar"')
          expect(matcher.inspect).to include(':baz=>"qux"')
        end
      end
    end
  end
end
