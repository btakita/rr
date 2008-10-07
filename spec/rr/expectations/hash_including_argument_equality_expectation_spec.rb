require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
module Expectations
  describe ArgumentEqualityExpectation, "with HashIncluding argument" do
    attr_reader :expectation, :expected_hash
    
    before do
      @expected_hash = {:texas => "Austin", :maine => "Augusta"}
    end
    
    describe "#exact_match?" do
      before do
        @expectation = ArgumentEqualityExpectation.new(hash_including(expected_hash))
      end
      
      it "returns true when passed in a HashIncluding matcher with the same hash" do
        expectation.should be_exact_match(WildcardMatchers::HashIncluding.new(expected_hash))
      end
      
      it "returns false when passed in a HashIncluding matcher with a different argument list" do
        expectation.should_not be_exact_match(WildcardMatchers::HashIncluding.new(:foo => 1))
      end

      it "returns false otherwise" do
        expectation.should_not be_exact_match("hello")
        expectation.should_not be_exact_match(:hello)
        expectation.should_not be_exact_match(1)
        expectation.should_not be_exact_match(nil)
        expectation.should_not be_exact_match(true)
        expectation.should_not be_exact_match()
      end
    end

    describe "#wildcard_match?" do
      before do
        @expectation = ArgumentEqualityExpectation.new(hash_including(expected_hash))
      end

      it "returns true when hash contains same key/values as the expectation" do
        expectation.should be_wildcard_match(expected_hash)
      end
      
      it "returns true when hash contains at least expectation's key/values" do
        expectation.should be_wildcard_match(expected_hash.merge(:oregon => "Salem"))
      end
      
      it "returns true when passed the same hash, even after the original is modified" do
        original_expected_hash = expected_hash.clone
        expected_hash[:texas] = nil
        expectation.should be_wildcard_match(original_expected_hash)
      end
      
      it "returns true even if one of the expectation's values is nil" do
        expectation = ArgumentEqualityExpectation.new(hash_including(:foo => nil))
        expectation.should be_wildcard_match({:foo => nil})
      end
      
      it "returns false when hash matches only some required key/values" do
        expectation.should_not be_wildcard_match({:texas => "Austin"})
      end
      
      it "returns false when hash matches all the keys but not all the values" do
        expectation.should_not be_wildcard_match({:texas => "Austin", :maine => "Portland"})
      end

      it "returns false when passed a hash that matches all values but not all keys" do
        expectation.should_not be_wildcard_match({:texas => "Austin", :georgia => "Augusta"})
      end

      it "returns true when an exact match" do
        expectation.should be_wildcard_match(hash_including(expected_hash))
      end

      it "returns false when not passed correct number of arguments" do
        expectation.should_not be_wildcard_match()
        expectation.should_not be_wildcard_match(:a, :b)
      end
    end
  end
end
end
