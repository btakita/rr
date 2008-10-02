require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe Regexp do
  attr_reader :matcher

  before do
    @matcher = /foo/
  end

  describe "#wildcard_match?" do
    before do
      @matching_object = Object.new
      def @matching_object.quack
      end
      def @matching_object.waddle
      end

      @partial_matching_object = Object.new
      def @partial_matching_object.quack
      end

      @not_match_object = Object.new
    end

    context "when passed-in String matches the Regexp" do
      it "returns true" do
        matcher.should be_wildcard_match("foobarbaz")
      end
    end

    context "when passed-in String does not match the Regexp" do
      it "returns false" do
        matcher.should_not be_wildcard_match("no match here")
      end
    end
  end
  
  describe "#inspect" do
    it "returns the regexp" do
      matcher.inspect.should == "/foo/"
    end
  end
end
