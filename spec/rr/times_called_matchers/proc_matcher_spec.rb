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
          expect(matcher).to be_possible_match(2)
          expect(matcher).to be_possible_match(3)
          expect(matcher).to be_possible_match(10)
        end
      end

      describe "#matches?" do
        it "returns false when lambda returns false" do
          expect(times.call(2)).to be_false
          matcher.should_not be_matches(2)
        end

        it "returns true when lambda returns true" do
          expect(times.call(3)).to be_true
          expect(matcher).to be_matches(3)
        end
      end

      describe "#attempt?" do
        it "always returns true" do
          expect(matcher).to be_attempt(2)
          expect(matcher).to be_attempt(3)
          expect(matcher).to be_attempt(10)
        end
      end

      describe "#terminal?" do
        it "returns false" do
          matcher.should_not be_terminal
        end
      end

      describe "#error_message" do
        it "has an error message" do
          expect(matcher.error_message(1)).to match(/Called 1 time.\nExpected #<Proc.*> times./)
        end
      end
    end

  end
end
