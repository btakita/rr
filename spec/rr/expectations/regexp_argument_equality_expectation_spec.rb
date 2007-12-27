require "spec/spec_helper"

module RR
module Expectations
  describe ArgumentEqualityExpectation, "#exact_match? with regexp argument" do
    before do
      @expectation = ArgumentEqualityExpectation.new(/abc/)
    end
    
    it "returns true when passed in an Regexp matcher with the same argument list" do
      @expectation.should be_exact_match(/abc/)
    end

    it "returns false when passed in an Regexp matcher with a different argument list" do
      @expectation.should_not be_exact_match(/def/)
    end

    it "returns false otherwise" do
      @expectation.should_not be_exact_match("abc")
      @expectation.should_not be_exact_match(:hello)
      @expectation.should_not be_exact_match(1)
      @expectation.should_not be_exact_match(nil)
      @expectation.should_not be_exact_match(true)
      @expectation.should_not be_exact_match()
    end
  end

  describe ArgumentEqualityExpectation, "#wildcard_match? with Regexp argument" do
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

      @expectation = ArgumentEqualityExpectation.new(/abc/)
    end

    it "returns true when string matches the regexp" do
      @expectation.should be_wildcard_match("Tabcola")
    end

    it "returns false when string does not match the regexp" do
      @expectation.should_not be_wildcard_match("no match here")
    end

    it "returns true when an exact match" do
      @expectation.should be_wildcard_match(/abc/)
    end

    it "returns false when not an exact match" do
      @expectation.should_not be_wildcard_match(/def/)
    end

    it "returns false when not passed correct number of arguments" do
      @expectation.should_not be_wildcard_match()
      @expectation.should_not be_wildcard_match('abc', 'abc')
    end
  end
end
end
