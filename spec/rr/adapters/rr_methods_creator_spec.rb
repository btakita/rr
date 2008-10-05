require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Adapters
    describe RRMethods do
      attr_reader :subject
      before(:each) do
        @subject = Object.new
      end

      after(:each) do
        RR.reset
      end

      describe "normal strategy definitions" do
        attr_reader :strategy_method_name
        def call_strategy(*args, &block)
          __send__(strategy_method_name, *args, &block)
        end

        describe "#mock" do
          before do
            @strategy_method_name = :mock
          end

          send("normal strategy definition")

          context "when passing no args" do
            it "returns a DoubleDefinitionCreator" do
              call_strategy.class.should == DoubleDefinitions::DoubleDefinitionCreator
            end
          end

          context "when passed a method_name argument" do
            it "creates a mock Double for method" do
              double_definition = mock(subject, :foobar).returns {:baz}
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

          send("normal strategy definition")

          context "when passing no args" do
            it "returns a DoubleDefinitionCreator" do
              call_strategy.class.should == DoubleDefinitions::DoubleDefinitionCreator
            end
          end

          context "when passed a method_name argument" do
            it "creates a stub Double for method when passed a method_name argument" do
              double_definition = stub(subject, :foobar).returns {:baz}
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

          send("normal strategy definition")

          context "when passing no args" do
            it "returns a DoubleDefinitionCreator" do
              call_strategy.class.should == DoubleDefinitions::DoubleDefinitionCreator
            end
          end

          context "when passed a method_name argument_expectation" do
            it "creates a mock Double for method" do
              double_definition = dont_allow(subject, :foobar)
              double_definition.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(0)
              double_definition.argument_expectation.class.should == RR::Expectations::AnyArgumentExpectation

              lambda do
                subject.foobar
              end.should raise_error(Errors::TimesCalledError)
              RR.reset
            end
          end
        end
      end

      describe "! strategy definitions" do
        attr_reader :strategy_method_name
        def call_strategy(*args, &definition_eval_block)
          __send__(strategy_method_name, *args, &definition_eval_block)
        end

        describe "#mock!" do
          before do
            @strategy_method_name = :mock!
          end

          send("! strategy definition")

          context "when passed a method_name argument" do
            it "sets #verification_strategy to Mock" do
              proxy = mock!(:foobar)
              proxy.double_definition_creator.verification_strategy.class.should == RR::DoubleDefinitions::Strategies::Verification::Mock
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
              proxy = stub!(:foobar)
              proxy.double_definition_creator.verification_strategy.class.should == RR::DoubleDefinitions::Strategies::Verification::Stub
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
              proxy = dont_allow!(:foobar)
              proxy.double_definition_creator.verification_strategy.class.should == RR::DoubleDefinitions::Strategies::Verification::DontAllow
            end
          end
        end
      end
    end
  end
end
