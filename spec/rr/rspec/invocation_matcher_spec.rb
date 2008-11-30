require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Adapters
    module Rspec
      describe InvocationMatcher do
        describe "matching against a method with no doubles" do
          before do
            @matcher = InvocationMatcher.new(:foobar)
            @result = @matcher.matches?(Object.new)
          end

          it "does not match" do
            @result.should_not be
          end
        end

        describe "defining an expectation using a method invocation" do
          before do
            @subject = Object.new
            stub(@subject).foobar
            @subject.foobar(:args)
            @result = InvocationMatcher.new.foobar(:args).matches?(@subject)
          end

          it "uses the invoked method as the expected method" do
            @result.should be
          end
        end

        describe "matching against a stubbed method that was never called" do
          before do
            @subject = Object.new
            stub(@subject).foobar
            @matcher = InvocationMatcher.new(:foobar)
            @result = @matcher.matches?(@subject)
          end

          it "does not match" do
            @result.should_not be
          end
        end

        describe "matching against a stubbed method that was called once" do
          before do
            @subject = Object.new
            stub(@subject).foobar
            @subject.foobar
            @result = InvocationMatcher.new(:foobar).matches?(@subject)
          end

          it "does match" do
            @result.should be
          end
        end

        describe "matching against a stubbed method that was called with unexpected arguments" do
          before do
            @args = %w(one two)
            @subject = Object.new
            stub(@subject).foobar
            @subject.foobar(:other)
            @result = InvocationMatcher.new(:foobar).with(*@args).matches?(@subject)
          end

          it "does not match" do
            @result.should_not be
          end
        end

        describe "matching against a stubbed method that was called with expected arguments" do
          before do
            @args = %w(one two)
            @subject = Object.new
            stub(@subject).foobar
            @subject.foobar(*@args)
            @result = InvocationMatcher.new(:foobar).with(*@args).matches?(@subject)
          end

          it "does match" do
            @result.should be
          end
        end

        describe "defining a fulfilled argument expectation using a method invocation" do
          before do
            @args = %w(one two)
            @subject = Object.new
            stub(@subject).foobar
            @subject.foobar(*@args)
            @result = InvocationMatcher.new.foobar(*@args).matches?(@subject)
          end

          it "does match" do
            @result.should be
          end
        end

        describe "defining an unfulfilled argument expectation using a method invocation" do
          before do
            @args = %w(one two)
            @subject = Object.new
            stub(@subject).foobar
            @subject.foobar(:other)
            @result = InvocationMatcher.new.foobar(*@args).matches?(@subject)
          end

          it "does not match" do
            @result.should_not be
          end
        end

        describe "matching against a stubbed method that was called more than once" do
          before do
            @subject = Object.new
            stub(@subject).foobar
            2.times { @subject.foobar }
            @result = InvocationMatcher.new(:foobar).twice.matches?(@subject)
          end

          it "does match" do
            @result.should be
          end
        end

        describe "matching a stubbed method with any arguments" do
          before do
            @subject = Object.new
            stub(@subject).foobar
            @subject.foobar(:args)
            @result = InvocationMatcher.new(:foobar).with_any_args.matches?(@subject)
          end

          it "does match" do
            @result.should be
          end
        end

        describe "matching a stubbed method with no arguments when arguments are not provided" do
          before do
            @subject = Object.new
            stub(@subject).foobar
            @subject.foobar
            @result = InvocationMatcher.new(:foobar).with_no_args.matches?(@subject)
          end

          it "does match" do
            @result.should be
          end
        end

        describe "matching a stubbed method with no arguments when arguments are provided" do
          before do
            @subject = Object.new
            stub(@subject).foobar
            @subject.foobar(:args)
            @result = InvocationMatcher.new(:foobar).with_no_args.matches?(@subject)
          end

          it "does not match" do
            @result.should_not be
          end
        end

        describe "matching a method that was called twice when expected once" do
          before do
            @subject = Object.new
            stub(@subject).foobar
            2.times { @subject.foobar }
            @matcher = InvocationMatcher.new(:foobar).times(1)
            @result = @matcher.matches?(@subject)
          end

          it "does not match" do
            @result.should_not be
          end
        end

        describe "matching a method that was called twice when expected twice" do
          before do
            @subject = Object.new
            stub(@subject).foobar
            2.times { @subject.foobar }
            @result = InvocationMatcher.new(:foobar).times(2).matches?(@subject)
          end

          it "does match" do
            @result.should be
          end
        end

        describe "matching a method that was called twice when any number of times" do
          before do
            @subject = Object.new
            stub(@subject).foobar
            2.times { @subject.foobar }
            @result = InvocationMatcher.new(:foobar).any_number_of_times.matches?(@subject)
          end

          it "does match" do
            @result.should be
          end
        end

        describe "matching a method that was called three times when expected at most twice" do
          before do
            @subject = Object.new
            stub(@subject).foobar
            3.times { @subject.foobar }
            @result = InvocationMatcher.new(:foobar).at_most(2).matches?(@subject)
          end

          it "does not match" do
            @result.should_not be
          end
        end

        describe "matching a method that was called once when expected at most twice" do
          before do
            @subject = Object.new
            stub(@subject).foobar
            @subject.foobar
            @result = InvocationMatcher.new(:foobar).at_most(2).matches?(@subject)
          end

          it "does match" do
            @result.should be
          end
        end

        describe "matching a method that was called once when expected at least twice" do
          before do
            @subject = Object.new
            stub(@subject).foobar
            @subject.foobar
            @result = InvocationMatcher.new(:foobar).at_least(2).matches?(@subject)
          end

          it "does not match" do
            @result.should_not be
          end
        end

        describe "matching a method that was called three times when expected at least twice" do
          before do
            @subject = Object.new
            stub(@subject).foobar
            3.times { @subject.foobar }
            @result = InvocationMatcher.new(:foobar).at_least(2).matches?(@subject)
          end

          it "does match" do
            @result.should be
          end
        end
      end
    end
  end
end
