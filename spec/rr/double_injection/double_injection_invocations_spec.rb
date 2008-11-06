require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe DoubleInjection do
      def new_double_injection(subject, method_name)
        double_injection = DoubleInjection.new(subject, method_name)
        Double.new(
          double_injection,
          DoubleDefinitions::DoubleDefinition.new(
            DoubleDefinitions::DoubleDefinitionCreator.new,
            subject
          )
        ).with_any_args.any_number_of_times
        double_injection.bind
        double_injection
      end

      describe "before having a method called" do
        before do
          @subject = Object.new
          @method_name = :foobar
          @double_injection = new_double_injection(@subject, @method_name)
        end

        it "has no invocations" do
          @double_injection.invocation(Expectations::AnyArgumentExpectation.new).should be_nil
        end
      end

      describe "after having a method called for the first time" do
        before do
          @subject = Object.new
          @method_name = :foobar
          @args = %w(one two)
          @double_injection = new_double_injection(@subject, @method_name)
          @subject.foobar(*@args)
        end

        it "has an invocation of the passed arguments" do
          @double_injection.invocation(Expectations::ArgumentEqualityExpectation.new(*@args)).
            should_not be_nil
        end

        it "the invocation count for the passed arguments is 1" do
          @double_injection.invocation(Expectations::ArgumentEqualityExpectation.new(*@args)).
            times_called.should == 1
        end
      end

      describe "after having a method called twice with the same arguments" do
        before do
          @subject = Object.new
          @method_name = :foobar
          @args = %w(one two)
          @double_injection = new_double_injection(@subject, @method_name)
          @subject.foobar(*@args)
          @subject.foobar(*@args)
        end

        it "has an invocation of the passed arguments" do
          @double_injection.invocation(Expectations::ArgumentEqualityExpectation.new(*@args)).
            should_not be_nil
        end

        it "the invocation count for the passed arguments is 2" do
          @double_injection.invocation(Expectations::ArgumentEqualityExpectation.new(*@args)).
            times_called.should == 2
        end
      end

      describe "after having a method called twice with different arguments" do
        before do
          @subject = Object.new
          @method_name = :foobar
          @double_injection = new_double_injection(@subject, @method_name)
          @arg_sets = [%w(one), %w(two)]
          @arg_sets.each {|args| @subject.foobar(*args) }
        end

        it "has an invocation of each argument set" do
          @arg_sets.each do |args|
            @double_injection.invocation(Expectations::ArgumentEqualityExpectation.new(*args)).
              should_not be_nil
          end
        end

        it "the invocation count for each argument set is 1" do
          @arg_sets.each do |args|
            @double_injection.invocation(Expectations::ArgumentEqualityExpectation.new(*args)).
              times_called.should == 1
          end
        end
      end
    end
  end
end
