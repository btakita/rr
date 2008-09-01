require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
module TimesCalledMatchers
  describe AtMostMatcher do
    attr_reader :matcher, :times
    before do
      @times = 3
      @matcher = AtMostMatcher.new(times)
    end
    
    describe AtMostMatcher, "#possible_match?" do
      it "returns true when times called < times" do
        matcher.should be_possible_match(2)
      end

      it "returns true when times called == times" do
        matcher.should be_possible_match(3)
      end

      it "returns false when times called > times" do
        matcher.should_not be_possible_match(4)
      end
    end

    describe AtMostMatcher, "#matches?" do
      it "returns true when times_called less than times" do
        matcher.should be_matches(2)
      end

      it "returns true when times_called == times" do
        matcher.should be_matches(3)
      end

      it "returns false when times_called > times" do
        matcher.should_not be_matches(4)
      end
    end

    describe AtMostMatcher, "#attempt?" do
      it "returns true when less than expected times" do
        matcher.should be_attempt(2)
      end

      it "returns false when == expected times" do
        matcher.should_not be_attempt(3)
      end

      it "returns false when > expected times" do
        matcher.should_not be_attempt(4)
      end
    end

    describe AnyTimesMatcher, "#terminal?" do
      it "returns true" do
        matcher.should be_terminal
      end
    end

    describe AtMostMatcher, "#error_message" do
      it "has an error message" do
        matcher.error_message(5).should == (
        "Called 5 times.\nExpected at most 3 times."
        )
      end
    end
  end

end
end
