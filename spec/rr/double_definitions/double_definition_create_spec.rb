require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe DoubleDefinitionCreate do
      attr_reader :double_definition_create, :subject, :strategy_method_name
      it_should_behave_like "Swapped Space"
      before(:each) do
        @subject = Object.new
        @double_definition_create = DoubleDefinitionCreate.new
      end

      describe "#root_subject" do
        it "returns #subject" do
          double_definition_create.stub(subject).foobar
          double_definition_create.root_subject.should == subject
        end
      end
      
      describe "StrategySetupMethods" do
        describe "normal strategy definitions" do
          def call_strategy(*args, &block)
            double_definition_create.__send__(strategy_method_name, *args, &block)
          end

          describe "#mock" do
            before do
              @strategy_method_name = :mock
            end

            context "when passing no args" do
              it "returns self" do
                call_strategy.should === double_definition_create
              end
            end

            context "when passed a subject and a method_name argument" do
              it "creates a mock Double for method" do
                double_definition = double_definition_create.mock(subject, :foobar).returns {:baz}
                double_definition.times_matcher.should == RR::TimesCalledMatchers::IntegerMatcher.new(1)
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

            context "when passing no args" do
              it "returns self" do
                call_strategy.should === double_definition_create
              end
            end

            context "when passed subject and a method_name argument" do
              it "creates a stub Double for method when passed a method_name argument" do
                double_definition = double_definition_create.stub(subject, :foobar).returns {:baz}
                double_definition.times_matcher.should == RR::TimesCalledMatchers::AnyTimesMatcher.new
                double_definition.argument_expectation.class.should == RR::Expectations::AnyArgumentExpectation
                subject.foobar.should == :baz
              end
            end
          end

          describe "#dont_allow" do
            before do
              @strategy_method_name = :dont_allow
            end

            context "when passing no args" do
              it "returns self" do
                call_strategy.should === double_definition_create
              end
            end

            context "when passed a subject and a method_name argument_expectation" do
              it "creates a mock Double for method" do
                double_definition = double_definition_create.dont_allow(subject, :foobar)
                double_definition.times_matcher.should == RR::TimesCalledMatchers::NeverMatcher.new
                double_definition.argument_expectation.class.should == RR::Expectations::AnyArgumentExpectation

                lambda do
                  subject.foobar
                end.should raise_error(RR::Errors::TimesCalledError)
                RR.reset
              end
            end
          end
        end

        describe "! strategy definitions" do
          attr_reader :strategy_method_name
          def call_strategy(*args, &definition_eval_block)
            double_definition_create.__send__(strategy_method_name, *args, &definition_eval_block)
          end

          describe "#mock!" do
            before do
              @strategy_method_name = :mock!
            end

            context "when passed a method_name argument" do
              it "sets #verification_strategy to Mock" do
                double_definition_create.mock!(:foobar)
                double_definition_create.verification_strategy.class.should == Strategies::Verification::Mock
                lambda {RR.verify}.should raise_error(::RR::Errors::TimesCalledError)
              end
            end
          end

          describe "#stub!" do
            before do
              @strategy_method_name = :stub!
            end

            context "when passed a method_name argument" do
              it "sets #verification_strategy to Stub" do
                double_definition_create.stub!(:foobar)
                double_definition_create.verification_strategy.class.should == Strategies::Verification::Stub
              end
            end
          end

          describe "#dont_allow!" do
            before do
              @strategy_method_name = :dont_allow!
            end

            context "when passed a method_name argument" do
              it "sets #verification_strategy to DontAllow" do
                double_definition_create.dont_allow!(:foobar)
                double_definition_create.verification_strategy.class.should == Strategies::Verification::DontAllow
              end
            end
          end
        end

        describe "#stub.proxy" do
          before do
            class << subject
              def foobar(*args)
                :original_foobar
              end
            end
          end

          context "when passed a method_name argument" do
            it "creates a proxy Double for method" do
              double_definition = double_definition_create.stub.proxy(subject, :foobar).after_call {:baz}
              double_definition.times_matcher.should == RR::TimesCalledMatchers::AnyTimesMatcher.new
              double_definition.argument_expectation.class.should == RR::Expectations::AnyArgumentExpectation
              subject.foobar.should == :baz
            end
          end
        end

        describe "#instance_of" do
          context "when not passed a class" do
            it "raises an ArgumentError" do
              lambda do
                double_definition_create.instance_of(Object.new).foobar
              end.should raise_error(ArgumentError, "instance_of only accepts class objects")
            end
          end

          context "when passed a method_name argument" do
            it "creates a proxy Double for method" do
              klass = Class.new
              double_definition = double_definition_create.stub.instance_of(klass, :foobar).returns {:baz}
              double_definition.times_matcher.should == RR::TimesCalledMatchers::AnyTimesMatcher.new
              double_definition.argument_expectation.class.should == RR::Expectations::AnyArgumentExpectation
              klass.new.foobar.should == :baz
            end
          end
        end

        describe "#instance_of.mock" do
          before do
            @klass = Class.new
          end

#          context "when passed no arguments" do
#            it "returns a DoubleDefinitiondouble_definition_create" do
#              instance_of.instance_of.should be_instance_of(DoubleDefinitionCreate)
#            end
#          end

          context "when passed a method_name argument" do
            it "creates a instance_of Double for method" do
              double_definition = instance_of.mock(@klass, :foobar)
              double_definition.with(1, 2) {:baz}
              double_definition.times_matcher.should == RR::TimesCalledMatchers::IntegerMatcher.new(1)
              double_definition.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
              double_definition.argument_expectation.expected_arguments.should == [1, 2]

              @klass.new.foobar(1, 2).should == :baz
            end
          end
        end
      end

      describe "StrategyExecutionMethods" do
        describe "#create" do
          context "when #verification_strategy is a Mock" do
            context "when #implementation_strategy is a Reimplementation" do
              before do
                double_definition_create.mock(subject)
              end

              it "sets expectation on the #subject that it will be sent the method_name once with the passed-in arguments" do
                mock(subject).foobar(1, 2)
                subject.foobar(1, 2)
                lambda {subject.foobar(1, 2)}.should raise_error(RR::Errors::TimesCalledError)
                lambda {RR.verify}.should raise_error(RR::Errors::TimesCalledError)
              end

              describe "#subject.method_name being called" do
                it "returns the return value of the Double#returns block" do
                  double_definition_create.call(:foobar, 1, 2) {:baz}
                  subject.foobar(1, 2).should == :baz
                end
              end
            end

            context "when #implementation_strategy is a Proxy" do
              before do
                double_definition_create.mock
                double_definition_create.proxy(subject)
              end

              it "sets expectation on the #subject that it will be sent the method_name once with the passed-in arguments" do
                def subject.foobar(*args)
                  :baz
                end
                mock(subject).foobar(1, 2)

                subject.foobar(1, 2)
                lambda {subject.foobar(1, 2)}.should raise_error(RR::Errors::TimesCalledError)
                lambda {RR.verify}.should raise_error(RR::Errors::TimesCalledError)
              end

              describe "#subject.method_name being called" do
                it "calls the original method" do
                  original_method_called = false
                  (class << subject; self; end).class_eval do
                    define_method(:foobar) do |*args|
                      original_method_called = true
                    end
                  end
                  double_definition_create.call(:foobar, 1, 2)
                  subject.foobar(1, 2)
                  original_method_called.should be_true
                end

                context "when not passed a block" do
                  it "returns the value of the original method" do
                    def subject.foobar(*args)
                      :baz;
                    end
                    double_definition_create.call(:foobar, 1, 2)
                    subject.foobar(1, 2).should == :baz
                  end
                end

                context "when passed a block" do
                  attr_reader :real_value
                  before do
                    @real_value = real_value = Object.new
                    (class << subject; self; end).class_eval do
                      define_method(:foobar) {|arg1, arg2| real_value}
                    end
                  end

                  it "calls the block with the return value of the original method" do
                    double_definition_create.call(:foobar, 1, 2) do |value|
                      mock(value).a_method {99}
                      value
                    end
                    subject.foobar(1, 2)
                    real_value.a_method.should == 99
                  end

                  it "returns the return value of the block" do
                    double_definition_create.call(:foobar, 1, 2) do |value|
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
                double_definition_create.stub(subject)
              end

              context "when not passed a block" do
                it "returns nil" do
                  double_definition_create.call(:foobar)
                  subject.foobar.should be_nil
                end
              end

              context "when passed a block" do
                describe "#subject.method_name being called" do
                  it "returns the return value of the block" do
                    double_definition_create.call(:foobar) {:baz}
                    subject.foobar.should == :baz
                  end
                end
              end

              context "when not passed args" do
                describe "#subject.method_name being called with any arguments" do
                  it "invokes the implementation of the Stub" do
                    double_definition_create.call(:foobar) {:baz}
                    subject.foobar(1, 2).should == :baz
                    subject.foobar().should == :baz
                    subject.foobar([]).should == :baz
                  end
                end
              end

              context "when passed args" do
                describe "#subject.method_name being called with the passed-in arguments" do
                  it "invokes the implementation of the Stub" do
                    double_definition_create.call(:foobar, 1, 2) {:baz}
                    subject.foobar(1, 2).should == :baz
                  end
                end

                describe "#subject.method_name being called with different arguments" do
                  it "raises a DoubleNotFoundError" do
                    double_definition_create.call(:foobar, 1, 2) {:baz}
                    lambda do
                      subject.foobar
                    end.should raise_error(RR::Errors::DoubleNotFoundError)
                  end
                end
              end
            end

            context "when #implementation_strategy is a Proxy" do
              before do
                def subject.foobar(*args)
                  :original_return_value
                end
                double_definition_create.stub
                double_definition_create.proxy(subject)
              end

              context "when not passed a block" do
                describe "#subject.method_name being called" do
                  it "invokes the original implementanion" do
                    double_definition_create.call(:foobar)
                    subject.foobar.should == :original_return_value
                  end
                end
              end

              context "when passed a block" do
                describe "#subject.method_name being called" do
                  it "invokes the original implementanion and invokes the block with the return value of the original implementanion" do
                    passed_in_value = nil
                    double_definition_create.call(:foobar) do |original_return_value|
                      passed_in_value = original_return_value
                    end
                    subject.foobar
                    passed_in_value.should == :original_return_value
                  end

                  it "returns the return value of the block" do
                    double_definition_create.call(:foobar) do |original_return_value|
                      :new_return_value
                    end
                    subject.foobar.should == :new_return_value
                  end
                end
              end

              context "when passed args" do
                describe "#subject.method_name being called with the passed-in arguments" do
                  it "invokes the implementation of the Stub" do
                    double_definition_create.call(:foobar, 1, 2) {:baz}
                    subject.foobar(1, 2).should == :baz
                  end
                end

                describe "#subject.method_name being called with different arguments" do
                  it "raises a DoubleNotFoundError" do
                    double_definition_create.call(:foobar, 1, 2) {:baz}
                    lambda do
                      subject.foobar
                    end.should raise_error(RR::Errors::DoubleNotFoundError)
                  end
                end
              end
            end
          end

          context "when #verification_strategy is a DontAllow" do
            before do
              double_definition_create.dont_allow(subject)
            end

            context "when not passed args" do
              describe "#subject.method_name being called with any arguments" do
                it "raises a TimesCalledError" do
                  double_definition_create.call(:foobar)
                  lambda {subject.foobar}.should raise_error(RR::Errors::TimesCalledError)
                  lambda {subject.foobar(1, 2)}.should raise_error(RR::Errors::TimesCalledError)
                end
              end
            end

            context "when passed args" do
              describe "#subject.method_name being called with the passed-in arguments" do
                it "raises a TimesCalledError" do
                  double_definition_create.call(:foobar, 1, 2)
                  lambda {subject.foobar(1, 2)}.should raise_error(RR::Errors::TimesCalledError)
                end
              end

              describe "#subject.method_name being called with different arguments" do
                it "raises a DoubleNotFoundError" do
                  double_definition_create.call(:foobar, 1, 2)
                  lambda {subject.foobar()}.should raise_error(RR::Errors::DoubleNotFoundError)
                end
              end
            end
          end
        end
      end
    end
  end
end