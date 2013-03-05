require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module TimesCalledMatchers
    describe AnyTimesMatcher do
      attr_reader :matcher
      before do
        @matcher = AnyTimesMatcher.new
      end

      describe AnyTimesMatcher, "#possible_match?" do
        it "always returns true" do
          expect(matcher).to be_possible_match(0)
          expect(matcher).to be_possible_match(99999)
        end
      end

      describe AnyTimesMatcher, "#matches?" do
        it "always returns true" do
          expect(matcher).to be_matches(0)
          expect(matcher).to be_matches(99999)
        end
      end

      describe AnyTimesMatcher, "#attempt?" do
        it "always returns true" do
          expect(matcher).to be_attempt(0)
          expect(matcher).to be_attempt(99999)
        end
      end

      describe AnyTimesMatcher, "#terminal?" do
        it "returns false" do
          matcher.should_not be_terminal
        end
      end

      describe AnyTimesMatcher, "#error_message" do
        it "has an error message" do
          expect(matcher.error_message(2)).to eq \
            "Called 2 times.\nExpected any number of times."
        end
      end
    end
  end
end
