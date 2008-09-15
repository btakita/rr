require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
module Expectations
  describe ArgumentEqualityExpectation, "with Satisfy argument" do
    attr_reader :expectation, :expectation_proc, :expected_value, :satisfy_matcher
    
    before do
      @expected_value = :foo
      @expectation_proc = lambda {|argument| argument == expected_value}
      @satisfy_matcher = satisfy(&expectation_proc)
      @expectation = ArgumentEqualityExpectation.new(satisfy_matcher)
    end
    
    describe "#exact_match?" do
      before do
      end
      
      it "returns true when passed a Satisfy matcher with the same proc" do
        expectation.should be_exact_match(WildcardMatchers::Satisfy.new(expectation_proc))
      end
      
      it "returns false when passed a Satisfy matcher with another proc" do
        expectation.should_not be_exact_match(WildcardMatchers::Satisfy.new(lambda {}))
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
      it "returns true when the proc returns a truthy value" do
        (!!expectation_proc.call(expected_value)).should be_true
        expectation.should be_wildcard_match(expected_value)
      end
      
      it "returns false when the proc returns a falsey value" do
        (!!expectation_proc.call(:bar)).should be_false
        expectation.should_not be_wildcard_match(:bar)
      end
      
      it "returns true when an exact match" do
        expectation.should be_wildcard_match(satisfy_matcher)
      end

      it "returns false when not passed correct number of arguments" do
        expectation.should_not be_wildcard_match()
        expectation.should_not be_wildcard_match(:a, :b)
      end
    end
  end
end
end
