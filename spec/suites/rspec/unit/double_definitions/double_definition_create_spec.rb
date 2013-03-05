require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe DoubleDefinitionCreate do
      subject { Object.new }

      attr_reader :double_definition_create, :strategy_method_name

      include_examples "Swapped Space"

      before(:each) do
        @double_definition_create = DoubleDefinitionCreate.new
      end

      describe "#root_subject" do
        it "returns #subject" do
          double_definition_create.stub(subject).foobar
          expect(double_definition_create.root_subject).to eq subject
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
                expect(call_strategy).to equal double_definition_create
              end
            end

            context "when passed a subject and a method_name argument" do
              it "creates a mock Double for method" do
                double_definition = double_definition_create.mock(subject, :foobar).returns {:baz}
                expect(double_definition.times_matcher).to eq RR::TimesCalledMatchers::IntegerMatcher.new(1)
                expect(double_definition.argument_expectation.class).to eq RR::Expectations::ArgumentEqualityExpectation
                expect(double_definition.argument_expectation.expected_arguments).to eq []
                expect(subject.foobar).to eq :baz
              end
            end
          end

          describe "#stub" do
            before do
              @strategy_method_name = :stub
            end

            context "when passing no args" do
              it "returns self" do
                expect(call_strategy).to equal double_definition_create
              end
            end

            context "when passed subject and a method_name argument" do
              it "creates a stub Double for method when passed a method_name argument" do
                double_definition = double_definition_create.stub(subject, :foobar).returns {:baz}
                expect(double_definition.times_matcher).to eq RR::TimesCalledMatchers::AnyTimesMatcher.new
                expect(double_definition.argument_expectation.class).to eq RR::Expectations::AnyArgumentExpectation
                expect(subject.foobar).to eq :baz
              end
            end
          end

          describe "#dont_allow" do
            before do
              @strategy_method_name = :dont_allow
            end

            context "when passing no args" do
              it "returns self" do
                expect(call_strategy).to equal double_definition_create
              end
            end

            context "when passed a subject and a method_name argument_expectation" do
              it "creates a mock Double for method" do
                double_definition = double_definition_create.dont_allow(subject, :foobar)
                expect(double_definition.times_matcher).to eq RR::TimesCalledMatchers::NeverMatcher.new
                expect(double_definition.argument_expectation.class).to eq RR::Expectations::AnyArgumentExpectation

                expect {
                  subject.foobar
                }.to raise_error(RR::Errors::TimesCalledError)
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
                expect(double_definition_create.verification_strategy.class).to eq Strategies::Verification::Mock
                expect { RR.verify }.to raise_error(::RR::Errors::TimesCalledError)
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
                expect(double_definition_create.verification_strategy.class).to eq Strategies::Verification::Stub
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
                expect(double_definition_create.verification_strategy.class).to eq Strategies::Verification::DontAllow
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
              expect(double_definition.times_matcher).to eq RR::TimesCalledMatchers::AnyTimesMatcher.new
              expect(double_definition.argument_expectation.class).to eq RR::Expectations::AnyArgumentExpectation
              expect(subject.foobar).to eq :baz
            end
          end
        end

        describe "#instance_of" do
          context "when not passed a class" do
            it "raises an ArgumentError" do
              expect {
                double_definition_create.instance_of(Object.new).foobar
              }.to raise_error(ArgumentError, "instance_of only accepts class objects")
            end
          end

          context "when passed a method_name argument" do
            it "creates a proxy Double for method" do
              klass = Class.new
              double_definition = double_definition_create.stub.instance_of(klass, :foobar).returns {:baz}
              expect(double_definition.times_matcher).to eq RR::TimesCalledMatchers::AnyTimesMatcher.new
              expect(double_definition.argument_expectation.class).to eq RR::Expectations::AnyArgumentExpectation
              expect(klass.new.foobar).to eq :baz
            end
          end
        end

        describe "#instance_of.mock" do
          before do
            @klass = Class.new
          end

#          context "when passed no arguments" do
#            it "returns a DoubleDefinitiondouble_definition_create" do
#              expect(instance_of.instance_of).to be_instance_of(DoubleDefinitionCreate)
#            end
#          end

          context "when passed a method_name argument" do
            it "creates a instance_of Double for method" do
              double_definition = instance_of.mock(@klass, :foobar)
              double_definition.with(1, 2) {:baz}
              expect(double_definition.times_matcher).to eq RR::TimesCalledMatchers::IntegerMatcher.new(1)
              expect(double_definition.argument_expectation.class).to eq RR::Expectations::ArgumentEqualityExpectation
              expect(double_definition.argument_expectation.expected_arguments).to eq [1, 2]

              expect(@klass.new.foobar(1, 2)).to eq :baz
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
                expect { subject.foobar(1, 2) }.to raise_error(RR::Errors::TimesCalledError)
                expect { RR.verify }.to raise_error(RR::Errors::TimesCalledError)
              end

              describe "#subject.method_name being called" do
                it "returns the return value of the Double#returns block" do
                  double_definition_create.call(:foobar, 1, 2) {:baz}
                  expect(subject.foobar(1, 2)).to eq :baz
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
                expect { subject.foobar(1, 2) }.to raise_error(RR::Errors::TimesCalledError)
                expect { RR.verify }.to raise_error(RR::Errors::TimesCalledError)
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
                  expect(original_method_called).to be_true
                end

                context "when not passed a block" do
                  it "returns the value of the original method" do
                    def subject.foobar(*args)
                      :baz;
                    end
                    double_definition_create.call(:foobar, 1, 2)
                    expect(subject.foobar(1, 2)).to eq :baz
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
                    expect(real_value.a_method).to eq 99
                  end

                  it "returns the return value of the block" do
                    double_definition_create.call(:foobar, 1, 2) do |value|
                      :something_else
                    end
                    expect(subject.foobar(1, 2)).to eq :something_else
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
                  expect(subject.foobar).to be_nil
                end
              end

              context "when passed a block" do
                describe "#subject.method_name being called" do
                  it "returns the return value of the block" do
                    double_definition_create.call(:foobar) {:baz}
                    expect(subject.foobar).to eq :baz
                  end
                end
              end

              context "when not passed args" do
                describe "#subject.method_name being called with any arguments" do
                  it "invokes the implementation of the Stub" do
                    double_definition_create.call(:foobar) {:baz}
                    expect(subject.foobar(1, 2)).to eq :baz
                    expect(subject.foobar()).to eq :baz
                    expect(subject.foobar([])).to eq :baz
                  end
                end
              end

              context "when passed args" do
                describe "#subject.method_name being called with the passed-in arguments" do
                  it "invokes the implementation of the Stub" do
                    double_definition_create.call(:foobar, 1, 2) {:baz}
                    expect(subject.foobar(1, 2)).to eq :baz
                  end
                end

                describe "#subject.method_name being called with different arguments" do
                  it "raises a DoubleNotFoundError" do
                    double_definition_create.call(:foobar, 1, 2) {:baz}
                    expect {
                      subject.foobar
                    }.to raise_error(RR::Errors::DoubleNotFoundError)
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
                    expect(subject.foobar).to eq :original_return_value
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
                    expect(passed_in_value).to eq :original_return_value
                  end

                  it "returns the return value of the block" do
                    double_definition_create.call(:foobar) do |original_return_value|
                      :new_return_value
                    end
                    expect(subject.foobar).to eq :new_return_value
                  end
                end
              end

              context "when passed args" do
                describe "#subject.method_name being called with the passed-in arguments" do
                  it "invokes the implementation of the Stub" do
                    double_definition_create.call(:foobar, 1, 2) {:baz}
                    expect(subject.foobar(1, 2)).to eq :baz
                  end
                end

                describe "#subject.method_name being called with different arguments" do
                  it "raises a DoubleNotFoundError" do
                    double_definition_create.call(:foobar, 1, 2) {:baz}
                    expect {
                      subject.foobar
                    }.to raise_error(RR::Errors::DoubleNotFoundError)
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
                  expect { subject.foobar }.to raise_error(RR::Errors::TimesCalledError)
                  expect { subject.foobar(1, 2) }.to raise_error(RR::Errors::TimesCalledError)
                end
              end
            end

            context "when passed args" do
              describe "#subject.method_name being called with the passed-in arguments" do
                it "raises a TimesCalledError" do
                  double_definition_create.call(:foobar, 1, 2)
                  expect { subject.foobar(1, 2) }.to raise_error(RR::Errors::TimesCalledError)
                end
              end

              describe "#subject.method_name being called with different arguments" do
                it "raises a DoubleNotFoundError" do
                  double_definition_create.call(:foobar, 1, 2)
                  expect { subject.foobar() }.to raise_error(RR::Errors::DoubleNotFoundError)
                end
              end
            end
          end
        end
      end
    end
  end
end
