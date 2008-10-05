require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe DoubleDefinitionCreator do
      class << self
        define_method("DoubleDefinitionCreator strategy definition") do
          describe "strategy definition" do
            def call_strategy(*args, &block)
              creator.__send__(strategy_method_name, *args, &block)
            end

            context "when passing no args" do
              it "returns self" do
                call_strategy.should === creator
              end
            end

            context "when passed a subject" do
              it "returns a DoubleDefinitionCreatorProxy" do
                double = call_strategy(subject).foobar
                double.should be_instance_of(DoubleDefinition)
              end
            end

            context "when passed a method name and a block" do
              it "raises an ArgumentError" do
                lambda do
                  call_strategy(subject, :foobar) {}
                end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
              end
            end

            context "when already using an ImplementationStrategy" do
              it "raises a DoubleDefinitionError" do
                creator.mock
                lambda do
                  call_strategy
                end.should raise_error(Errors::DoubleDefinitionError, "This Double already has a mock strategy")
              end
            end
          end
        end
      end

      attr_reader :creator, :subject, :strategy_method_name
      it_should_behave_like "Swapped Space"
      before(:each) do
        @subject = Object.new
        @creator = DoubleDefinitionCreator.new
      end

      describe "#mock" do
        before do
          @strategy_method_name = :mock
        end
        
        send("DoubleDefinitionCreator strategy definition")

        context "when passed a method_name argument" do
          it "creates a mock Double for method" do
            double_definition = creator.mock(subject, :foobar).returns {:baz}
            double_definition.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
            double_definition.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
            double_definition.argument_expectation.expected_arguments.should == []
            subject.foobar.should == :baz
          end
        end
      end

      describe "#stub" do
        before do
          @strategy_method_name = :stub
        end
        
        send("DoubleDefinitionCreator strategy definition")

        context "when passed a method_name argument" do
          it "creates a stub Double for method when passed a method_name argument" do
            double_definition = creator.stub(subject, :foobar).returns {:baz}
            double_definition.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
            double_definition.argument_expectation.class.should == RR::Expectations::AnyArgumentExpectation
            subject.foobar.should == :baz
          end
        end
      end

      describe "#dont_allow" do
        before do
          @strategy_method_name = :dont_allow
        end
        
        send("DoubleDefinitionCreator strategy definition")

        it "raises error when proxied" do
          creator.proxy
          lambda do
            creator.dont_allow
          end.should raise_error(Errors::DoubleDefinitionError, "Doubles cannot be proxied when using dont_allow strategy")
        end

        context "when passed a method_name argument_expectation" do
          it "creates a mock Double for method" do
            double_definition = creator.dont_allow(subject, :foobar)
            double_definition.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(0)
            double_definition.argument_expectation.class.should == RR::Expectations::AnyArgumentExpectation

            lambda do
              subject.foobar
            end.should raise_error(Errors::TimesCalledError)
            RR.reset
          end
        end
      end

      describe "(#proxy or #proxy) and #stub" do
        before do
          class << subject
            def foobar(*args)
              :original_foobar
            end
          end
        end

        it "raises error when using dont_allow strategy" do
          creator.dont_allow
          lambda do
            creator.proxy
          end.should raise_error(Errors::DoubleDefinitionError, "Doubles cannot be proxied when using dont_allow strategy")
        end

        context "when passed a method_name argument" do
          it "creates a proxy Double for method" do
            double_definition = creator.stub.proxy(subject, :foobar).after_call {:baz}
            double_definition.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
            double_definition.argument_expectation.class.should == RR::Expectations::AnyArgumentExpectation
            subject.foobar.should == :baz
          end
        end
      end

      describe "#instance_of" do
        it "raises an error when not passed a class" do
          lambda do
            creator.instance_of(Object.new)
          end.should raise_error(ArgumentError, "instance_of only accepts class objects")
        end

        context "when passed a method_name argument" do
          it "creates a proxy Double for method" do
            klass = Class.new
            double_definition = creator.stub.instance_of(klass, :foobar).returns {:baz}
            double_definition.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
            double_definition.argument_expectation.class.should == RR::Expectations::AnyArgumentExpectation
            klass.new.foobar.should == :baz
          end
        end
      end

      describe "#instance_of and #mock" do
        before do
          @klass = Class.new
        end

        context "when passed no arguments" do
          it "returns a DoubleDefinitionCreator" do
            instance_of.instance_of.should be_instance_of(DoubleDefinitionCreator)
          end
        end

        context "when passed a method_name argument" do
          it "creates a instance_of Double for method" do
            double_definition = instance_of.mock(@klass, :foobar)
            double_definition.with(1, 2) {:baz}
            double_definition.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
            double_definition.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
            double_definition.argument_expectation.expected_arguments.should == [1, 2]

            @klass.new.foobar(1, 2).should == :baz
          end
        end
      end

      describe "#create" do
        context "when #verification_strategy is not set" do
          it "raises a DoubleDefinitionError" do
            lambda do
              creator.create(subject, :foobar, 1, 2)
            end.should raise_error(Errors::DoubleDefinitionError, "This Double has no strategy")
          end
        end
        
        context "when #verification_strategy is a Mock" do
          context "when #implementation_strategy is a Reimplementation" do
            before do
              creator.mock
            end

            it "sets expectation on the #subject that it will be sent the method_name once with the passed-in arguments" do
              creator.create(subject, :foobar, 1, 2)
              subject.foobar(1, 2)
              lambda {subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
            end
            
            describe "#subject.method_name being called" do
              it "returns the return value of the Double#returns block" do
                creator.create(subject, :foobar, 1, 2) {:baz}
                subject.foobar(1, 2).should == :baz
              end
            end
          end

          context "when #implementation_strategy is a Proxy" do
            before do
              creator.mock
              creator.proxy
            end

            it "sets expectation on the #subject that it will be sent the method_name once with the passed-in arguments" do
              def subject.foobar(*args)
                :baz;
              end
              creator.create(subject, :foobar, 1, 2)
              subject.foobar(1, 2)
              lambda {subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
            end

            describe "#subject.method_name being called" do
              it "calls the original method" do
                original_method_called = false
                (class << subject; self; end).class_eval do
                  define_method(:foobar) do |*args|
                    original_method_called = true
                  end
                end
                creator.create(subject, :foobar, 1, 2)
                subject.foobar(1, 2)
                original_method_called.should be_true
              end

              context "when not passed a block" do
                it "returns the value of the original method" do
                  def subject.foobar(*args)
                    :baz;
                  end
                  creator.create(subject, :foobar, 1, 2)
                  subject.foobar(1, 2).should == :baz
                end
              end

              context "when passed a block" do
                attr_reader :real_value
                before do
                  @real_value = real_value = Object.new
                  (class << subject; self; end).class_eval do
                    define_method(:foobar) {real_value}
                  end
                end

                it "calls the block with the return value of the original method" do
                  creator.create(subject, :foobar, 1, 2) do |value|
                    mock(value).a_method {99}
                    value
                  end
                  subject.foobar(1, 2)
                  real_value.a_method.should == 99
                end

                it "returns the return value of the block" do
                  creator.create(subject, :foobar, 1, 2) do |value|
                    :something_else
                  end
                  subject.foobar(1, 2).should == :something_else
                end
              end
            end
          end
        end

        context "when #verification_strategy is a Stub" do
          context "when #implementation_strategy is a Reimplementation" do
            before do
              creator.stub
            end

            it "stubs the subject without any args" do
              creator.create(subject, :foobar) {:baz}
              subject.foobar.should == :baz
            end

            it "stubs the subject mapping passed in args with the output" do
              creator.create(subject, :foobar, 1, 2) {:one_two}
              creator.create(subject, :foobar, 1) {:one}
              creator.create(subject, :foobar) {:nothing}
              subject.foobar.should == :nothing
              subject.foobar(1).should == :one
              subject.foobar(1, 2).should == :one_two
            end
          end

          context "when #implementation_strategy is a Proxy" do
            before do
              creator.stub
              creator.proxy
            end

            it "sets up a double with passed in arguments" do
              def subject.foobar(*args)
                :baz
              end
              creator.create(subject, :foobar, 1, 2)
              lambda do
                subject.foobar
              end.should raise_error(Errors::DoubleNotFoundError)
            end

            it "sets expectations on the subject while calling the original method" do
              def subject.foobar(*args)
                :baz
              end
              creator.create(subject, :foobar, 1, 2) {:new_value}
              10.times do
                subject.foobar(1, 2).should == :new_value
              end
            end

            it "sets after_call on the double when passed a block" do
              real_value = Object.new
              (class << subject; self; end).class_eval do
                define_method(:foobar) {real_value}
              end
              creator.create(subject, :foobar, 1, 2) do |value|
                mock(value).a_method {99}
                value
              end

              return_value = subject.foobar(1, 2)
              return_value.should === return_value
              return_value.a_method.should == 99
            end
          end
        end

        context "when #verification_strategy is a DontAllow" do
          before do
            creator.dont_allow
          end

          it "sets expectation for method to never be called with any arguments when on arguments passed in" do
            creator.create(subject, :foobar)
            lambda {subject.foobar}.should raise_error(Errors::TimesCalledError)
            lambda {subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
          end

          it "sets expectation for method to never be called with passed in arguments" do
            creator.create(subject, :foobar, 1, 2)
            lambda {subject.foobar}.should raise_error(Errors::DoubleNotFoundError)
            lambda {subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
          end

          it "sets expectation for method to never be called with no arguments when with_no_args is set" do
            creator.create(subject, :foobar).with_no_args
            lambda {subject.foobar}.should raise_error(Errors::TimesCalledError)
            lambda {subject.foobar(1, 2)}.should raise_error(Errors::DoubleNotFoundError)
          end
        end
      end
    end
  end
end