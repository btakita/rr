require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module TimesCalledMatchers
    describe ProcMatcher do
      attr_reader :matcher, :times
      before do
        @times = lambda {|other| other == 3}
        @matcher = ProcMatcher.new(times)
      end
      
      describe "#possible_match?" do
        it "always returns true" do
          matcher.should be_possible_match(2)
          matcher.should be_possible_match(3)
          matcher.should be_possible_match(10)
        end
      end

      describe "#matches?" do
        it "returns false when lambda returns false" do
          times.call(2).should be_false
          matcher.should_not be_matches(2)
        end

        it "returns true when lambda returns true" do
          times.call(3).should be_true
          matcher.should be_matches(3)
        end
      end

      describe "#attempt?" do
        it "always returns true" do
          matcher.should be_attempt(2)
          matcher.should be_attempt(3)
          matcher.should be_attempt(10)
        end
      end

      describe "#terminal?" do
        it "returns false" do
          matcher.should_not be_terminal
        end
      end

      describe "#error_message" do
        it "has an error message" do
          matcher.error_message(1).should =~
          /Called 1 time.\nExpected #<Proc.*> times./
        end
      end
    end

  end
end
