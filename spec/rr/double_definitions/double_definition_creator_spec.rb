require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe DoubleDefinitionCreator do
      attr_reader :creator, :subject, :strategy_method_name
      it_should_behave_like "Swapped Space"
      before(:each) do
        @subject = Object.new
        @creator = DoubleDefinitionCreator.new
      end

      describe "#root_subject" do
        it "returns #subject" do
          creator.stub(subject).foobar
          creator.root_subject.should == subject
        end
      end
      
      describe "StrategySetupMethods" do
        describe "normal strategy definitions" do
          def call_strategy(*args, &block)
            creator.__send__(strategy_method_name, *args, &block)
          end

          describe "#mock" do
            before do
              @strategy_method_name = :mock
            end

            send("normal strategy definition")

            context "when passing no args" do
              it "returns self" do
                call_strategy.should === creator
              end
            end

            context "when passed a subject and a method_name argument" do
              it "creates a mock Double for method" do
                double_definition = creator.mock(subject, :foobar).returns {:baz}
                double_definition.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
                double_definition.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
                double_definition.argument_expectation.expected_arguments.should == []
                subject.foobar.should == :baz
              end
            end

            context "when already using an ImplementationStrategy" do
              it "raises a DoubleDefinitionError" do
                creator.mock
                lambda do
                  call_strategy
                end.should raise_error(RR::Errors::DoubleDefinitionError, "This Double already has a mock strategy")
              end
            end
          end

          describe "#stub" do
            before do
              @strategy_method_name = :stub
            end

            send("normal strategy definition")

            context "when passing no args" do
              it "returns self" do
                call_strategy.should === creator
              end
            end

            context "when passed subject and a method_name argument" do
              it "creates a stub Double for method when passed a method_name argument" do
                double_definition = creator.stub(subject, :foobar).returns {:baz}
                double_definition.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
                double_definition.argument_expectation.class.should == RR::Expectations::AnyArgumentExpectation
                subject.foobar.should == :baz
              end
            end

            context "when already using an ImplementationStrategy" do
              it "raises a DoubleDefinitionError" do
                creator.mock
                lambda do
                  call_strategy
                end.should raise_error(RR::Errors::DoubleDefinitionError, "This Double already has a mock strategy")
              end
            end
          end

          describe "#dont_allow" do
            before do
              @strategy_method_name = :dont_allow
            end

            send("normal strategy definition")

            context "when passing no args" do
              it "returns self" do
                call_strategy.should === creator
              end
            end

            it "raises error when proxied" do
              creator.proxy
              lambda do
                creator.dont_allow
              end.should raise_error(Errors::DoubleDefinitionError, "Doubles cannot be proxied when using dont_allow strategy")
            end

            context "when passed a subject and a method_name argument_expectation" do
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

            context "when already using an ImplementationStrategy" do
              it "raises a DoubleDefinitionError" do
                creator.mock
                lambda do
                  call_strategy
                end.should raise_error(RR::Errors::DoubleDefinitionError, "This Double already has a mock strategy")
              end
            end
          end
        end

        describe "! strategy definitions" do
          attr_reader :strategy_method_name
          def call_strategy(*args, &definition_eval_block)
            creator.__send__(strategy_method_name, *args, &definition_eval_block)
          end

          describe "#mock!" do
            before do
              @strategy_method_name = :mock!
            end

            send("! strategy definition")

            context "when passed a method_name argument" do
              it "sets #verification_strategy to Mock" do
                creator.mock!(:foobar)
                creator.verification_strategy.class.should == Strategies::Verification::Mock
              end
            end
          end

          describe "#stub!" do
            before do
              @strategy_method_name = :stub!
            end

            send("! strategy definition")

            context "when passed a method_name argument" do
              it "sets #verification_strategy to Stub" do
                creator.stub!(:foobar)
                creator.verification_strategy.class.should == Strategies::Verification::Stub
              end
            end
          end

          describe "#dont_allow!" do
            before do
              @strategy_method_name = :dont_allow!
            end

            send("! strategy definition")

            context "when passed a method_name argument" do
              it "sets #verification_strategy to DontAllow" do
                creator.dont_allow!(:foobar)
                creator.verification_strategy.class.should == Strategies::Verification::DontAllow
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

          context "when already using Strategies::Verification::DontAllow" do
            it "raises error" do
              creator.dont_allow
              lambda do
                creator.proxy
              end.should raise_error(Errors::DoubleDefinitionError, "Doubles cannot be proxied when using dont_allow strategy")
            end
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
          context "when not passed a class" do
            it "raises an ArgumentError" do
              lambda do
                creator.instance_of(Object.new)
              end.should raise_error(ArgumentError, "instance_of only accepts class objects")
            end
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

        describe "#instance_of.mock" do
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
      end

      describe "StrategyExecutionMethods" do
        describe "#create" do
          context "when #verification_strategy is not set" do
            it "raises a DoubleDefinitionError" do
              lambda do
                creator.create(:foobar, 1, 2)
              end.should raise_error(Errors::DoubleDefinitionError, "This Double has no strategy")
            end
          end

          context "when #verification_strategy is a Mock" do
            context "when #implementation_strategy is a Reimplementation" do
              before do
                creator.mock(subject)
              end

              it "sets expectation on the #subject that it will be sent the method_name once with the passed-in arguments" do
                creator.create(:foobar, 1, 2)
                subject.foobar(1, 2)
                lambda {subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
              end

              describe "#subject.method_name being called" do
                it "returns the return value of the Double#returns block" do
                  creator.create(:foobar, 1, 2) {:baz}
                  subject.foobar(1, 2).should == :baz
                end
              end
            end

            context "when #implementation_strategy is a Proxy" do
              before do
                creator.mock
                creator.proxy(subject)
              end

              it "sets expectation on the #subject that it will be sent the method_name once with the passed-in arguments" do
                def subject.foobar(*args)
                  :baz;
                end
                creator.create(:foobar, 1, 2)
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
                  creator.create(:foobar, 1, 2)
                  subject.foobar(1, 2)
                  original_method_called.should be_true
                end

                context "when not passed a block" do
                  it "returns the value of the original method" do
                    def subject.foobar(*args)
                      :baz;
                    end
                    creator.create(:foobar, 1, 2)
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
                    creator.create(:foobar, 1, 2) do |value|
                      mock(value).a_method {99}
                      value
                    end
                    subject.foobar(1, 2)
                    real_value.a_method.should == 99
                  end

                  it "returns the return value of the block" do
                    creator.create(:foobar, 1, 2) do |value|
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
                creator.stub(subject)
              end

              context "when not passed a block" do
                it "returns nil" do
                  creator.create(:foobar)
                  subject.foobar.should be_nil
                end
              end

              context "when passed a block" do
                describe "#subject.method_name being called" do
                  it "returns the return value of the block" do
                    creator.create(:foobar) {:baz}
                    subject.foobar.should == :baz
                  end
                end
              end

              context "when not passed args" do
                describe "#subject.method_name being called with any arguments" do
                  it "invokes the implementation of the Stub" do
                    creator.create(:foobar) {:baz}
                    subject.foobar(1, 2).should == :baz
                    subject.foobar().should == :baz
                    subject.foobar([]).should == :baz
                  end
                end
              end

              context "when passed args" do
                describe "#subject.method_name being called with the passed-in arguments" do
                  it "invokes the implementation of the Stub" do
                    creator.create(:foobar, 1, 2) {:baz}
                    subject.foobar(1, 2).should == :baz
                  end
                end

                describe "#subject.method_name being called with different arguments" do
                  it "raises a DoubleNotFoundError" do
                    creator.create(:foobar, 1, 2) {:baz}
                    lambda do
                      subject.foobar
                    end.should raise_error(Errors::DoubleNotFoundError)
                  end
                end
              end
            end

            context "when #implementation_strategy is a Proxy" do
              before do
                def subject.foobar(*args)
                  :original_return_value
                end
                creator.stub
                creator.proxy(subject)
              end

              context "when not passed a block" do
                describe "#subject.method_name being called" do
                  it "invokes the original implementanion" do
                    creator.create(:foobar)
                    subject.foobar.should == :original_return_value
                  end
                end
              end

              context "when passed a block" do
                describe "#subject.method_name being called" do
                  it "invokes the original implementanion and invokes the block with the return value of the original implementanion" do
                    passed_in_value = nil
                    creator.create(:foobar) do |original_return_value|
                      passed_in_value = original_return_value
                    end
                    subject.foobar
                    passed_in_value.should == :original_return_value
                  end

                  it "returns the return value of the block" do
                    creator.create(:foobar) do |original_return_value|
                      :new_return_value
                    end
                    subject.foobar.should == :new_return_value
                  end
                end
              end

              context "when passed args" do
                describe "#subject.method_name being called with the passed-in arguments" do
                  it "invokes the implementation of the Stub" do
                    creator.create(:foobar, 1, 2) {:baz}
                    subject.foobar(1, 2).should == :baz
                  end
                end

                describe "#subject.method_name being called with different arguments" do
                  it "raises a DoubleNotFoundError" do
                    creator.create(:foobar, 1, 2) {:baz}
                    lambda do
                      subject.foobar
                    end.should raise_error(Errors::DoubleNotFoundError)
                  end
                end
              end
            end
          end

          context "when #verification_strategy is a DontAllow" do
            before do
              creator.dont_allow(subject)
            end

            context "when not passed args" do
              describe "#subject.method_name being called with any arguments" do
                it "raises a TimesCalledError" do
                  creator.create(:foobar)
                  lambda {subject.foobar}.should raise_error(Errors::TimesCalledError)
                  lambda {subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
                end
              end
            end

            context "when passed args" do
              describe "#subject.method_name being called with the passed-in arguments" do
                it "raises a TimesCalledError" do
                  creator.create(:foobar, 1, 2)
                  lambda {subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
                end
              end

              describe "#subject.method_name being called with different arguments" do
                it "raises a DoubleNotFoundError" do
                  creator.create(:foobar, 1, 2)
                  lambda {subject.foobar()}.should raise_error(Errors::DoubleNotFoundError)
                end
              end
            end
          end
        end
      end
    end
  end
end