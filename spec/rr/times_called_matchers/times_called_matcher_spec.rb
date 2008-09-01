require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module TimesCalledMatchers
    describe TimesCalledMatcher do
      describe ".create" do
        describe "when passed a AnyTimesMatcher" do
          it "returns the passed in argument" do
            matcher = AnyTimesMatcher.new
            TimesCalledMatcher.create(matcher).should === matcher
          end
        end

        describe "when passed a AtLeastMatcher" do
          it "returns the passed in argument" do
            matcher = AtLeastMatcher.new(5)
            TimesCalledMatcher.create(matcher).should === matcher
          end
        end

        describe "when passed a AtMostMatcher" do
          it "returns the passed in argument" do
            matcher = AtMostMatcher.new(5)
            TimesCalledMatcher.create(matcher).should === matcher
          end
        end
        
        describe "when passed a IntegerMatcher" do
          it "returns the passed in argument" do
            matcher = IntegerMatcher.new(5)
            TimesCalledMatcher.create(matcher).should === matcher
          end
        end

        describe "when passed a Integer" do
          it "returns IntegerMatcher" do
            TimesCalledMatcher.create(5).should == IntegerMatcher.new(5)
          end
        end

        describe "when passed a ProcMatcher" do
          it "returns the passed in argument" do
            matcher = ProcMatcher.new(lambda {|other| other == 5})
            TimesCalledMatcher.create(matcher).should === matcher
          end
        end

        describe "when passed a Lambda" do
          it "returns ProcMatcher" do
            value = lambda {|other| other == 5}
            TimesCalledMatcher.create(value).should == ProcMatcher.new(value)
          end
        end

        describe "when passed a IntegerMatcher" do
          it "returns the passed in argument" do
            matcher = RangeMatcher.new(2..4)
            TimesCalledMatcher.create(matcher).should === matcher
          end
        end

        describe "when passed a Integer" do
          it "returns RangeMatcher" do
            TimesCalledMatcher.create(2..4).should == RangeMatcher.new(2..4)
          end
        end

        describe "when passed a TimesCalledMatcher" do
          it "returns the passed in argument" do
            matcher = TimesCalledMatcher.new(5)
            TimesCalledMatcher.create(matcher).should === matcher
          end
        end

        describe "when passed an unsupported type" do
          it "raises an ArgumentError" do
            matcher = Object.new
            lambda do
              TimesCalledMatcher.create(matcher)
            end.should raise_error(ArgumentError, "There is no TimesCalledMatcher for #{matcher.inspect}.")
          end
        end
      end

      describe "#error_message" do
        before do
          @times = 3
          @matcher = TimesCalledMatcher.new(@times)
        end

        it "has an error message" do
          @matcher.error_message(5).should == (
          "Called 5 times.\nExpected 3 times."
          )
        end
      end

      describe "#==" do
        before do
          @times = 3
          @matcher = TimesCalledMatcher.new(@times)
        end

        it "returns true when other is the same class and times are ==" do
          @matcher.should == TimesCalledMatcher.new(@times)
        end

        it "returns false when other is a different class and times are ==" do
          @matcher.should_not == IntegerMatcher.new(@times)
        end

        it "returns false when is the same class and times are not ==" do
          @matcher.should_not == TimesCalledMatcher.new(1)
        end
      end
    end
  end
end
