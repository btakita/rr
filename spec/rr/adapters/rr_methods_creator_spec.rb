require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Adapters
    describe RRMethods do
      describe "#mock" do
        it_should_behave_like "RR::Adapters::RRMethods"

        before do
          @subject = Object.new
          class << @subject
            def foobar(*args)
              :original_value
            end
          end
        end

        it "returns a DoubleDefinitions::DoubleDefinitionCreator when passed no arguments" do
          mock.should be_instance_of(DoubleDefinitions::DoubleDefinitionCreator)
        end

        it "sets up the RR mock call chain" do
          creates_mock_call_chain(mock(@subject))
        end

        it "#rr_mock sets up the RR mock call chain" do
          creates_mock_call_chain(rr_mock(@subject))
        end

        it "creates a mock Double for method when passed a second argument" do
          creates_double_with_method_name(mock(@subject, :foobar))
        end

        it "creates a mock Double for method when passed a second argument with rr_mock" do
          creates_double_with_method_name(rr_mock(@subject, :foobar))
        end

        it "raises error if passed a method name and a block" do
          lambda do
            mock(@subject, :foobar) {}
          end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
        end

        def creates_double_with_method_name(double)
          double.with(1, 2) {:baz}
          double.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          double.argument_expectation.expected_arguments.should == [1, 2]

          @subject.foobar(1, 2).should == :baz
        end

        def creates_mock_call_chain(creator)
          double = creator.foobar(1, 2) {:baz}
          double.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          double.argument_expectation.expected_arguments.should == [1, 2]

          @subject.foobar(1, 2).should == :baz
        end
      end

      describe "#stub" do
        it_should_behave_like "RR::Adapters::RRMethods"

        before do
          @subject = Object.new
          class << @subject
            def foobar(*args)
              :original_value
            end
          end
        end

        it "returns a DoubleDefinitions::DoubleDefinitionCreator when passed no arguments" do
          stub.should be_instance_of(DoubleDefinitions::DoubleDefinitionCreator)
        end

        it "sets up the RR stub call chain" do
          creates_stub_call_chain(stub(@subject))
        end

        it "#rr_stub sets up the RR stub call chain" do
          creates_stub_call_chain(rr_stub(@subject))
        end

        it "creates a stub Double for method when passed a second argument" do
          creates_double_with_method_name(stub(@subject, :foobar))
        end

        it "#rr_stub creates a stub Double for method when passed a second argument" do
          creates_double_with_method_name(rr_stub(@subject, :foobar))
        end

        it "raises error if passed a method name and a block" do
          lambda do
            stub(@subject, :foobar) {}
          end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
        end

        def creates_double_with_method_name(double)
          double.with(1, 2) {:baz}
          double.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          @subject.foobar(1, 2).should == :baz
        end

        def creates_stub_call_chain(creator)
          double = creator.foobar(1, 2) {:baz}
          double.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          @subject.foobar(1, 2).should == :baz
        end
      end

      describe "#proxy and #mock" do
        it_should_behave_like "RR::Adapters::RRMethods"

        before do
          @subject = Object.new
          class << @subject
            def foobar(*args)
              :original_value
            end
          end
        end

        it "#proxy returns a DoubleDefinitions::DoubleDefinitionCreator when passed no arguments" do
          proxy.should be_instance_of(DoubleDefinitions::DoubleDefinitionCreator)
        end

        it "#proxy sets up the RR proxy call chain" do
          creates_mock_proxy_call_chain(mock.proxy(@subject))
        end

        it "#rr_proxy sets up the RR proxy call chain" do
          creates_mock_proxy_call_chain(rr_mock.proxy(@subject))
        end

        it "#mock_proxy sets up the RR proxy call chain" do
          creates_mock_proxy_call_chain(mock.proxy(@subject))
        end

        it "#rr_mock_proxy sets up the RR proxy call chain with rr_proxy" do
          creates_mock_proxy_call_chain(rr_mock.proxy(@subject))
        end

        it "#proxy creates a mock Double for method when passed a second argument" do
          creates_double_with_method_name(mock.proxy(@subject, :foobar))
        end

        it "#rr_proxy creates a mock Double for method when passed a second argument with rr_mock" do
          creates_double_with_method_name(rr_proxy.mock(@subject, :foobar))
        end

        it "#mock_proxy creates a mock Double for method when passed a second argument" do
          creates_double_with_method_name(mock.proxy(@subject, :foobar))
        end

        it "#rr_mock_proxy creates a mock Double for method when passed a second argument with rr_mock" do
          creates_double_with_method_name(rr_mock.proxy(@subject, :foobar))
        end

        it "raises error if passed a method name and a block" do
          lambda do
            mock.proxy(@subject, :foobar) {}
          end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
        end

        def creates_double_with_method_name(double)
          double.with(1, 2)
          double.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          double.argument_expectation.expected_arguments.should == [1, 2]

          @subject.foobar(1, 2).should == :original_value
        end

        def creates_mock_proxy_call_chain(creator)
          double = creator.foobar(1, 2)
          double.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          double.argument_expectation.expected_arguments.should == [1, 2]

          @subject.foobar(1, 2).should == :original_value
        end
      end

      describe "#stub and #proxy" do
        it_should_behave_like "RR::Adapters::RRMethods"

        before do
          @subject = Object.new
          class << @subject
            def foobar(*args)
              :original_value
            end
          end
        end

        it "returns a DoubleDefinitions::DoubleDefinitionCreator when passed no arguments" do
          stub.proxy.should be_instance_of(DoubleDefinitions::DoubleDefinitionCreator)
        end

        it "sets up the RR proxy call chain" do
          creates_stub_proxy_call_chain(stub.proxy(@subject))
        end

        it "sets up the RR proxy call chain" do
          creates_stub_proxy_call_chain(rr_stub.proxy(@subject))
        end

        it "#stub.proxy creates a stub Double for method when passed a second argument" do
          creates_double_with_method_name(stub.proxy(@subject, :foobar))
        end

        it "#rr_stub.proxy creates a stub Double for method when passed a second argument with rr_stub" do
          creates_double_with_method_name(rr_stub.proxy(@subject, :foobar))
        end

        it "raises error if passed a method name and a block" do
          lambda do
            stub.proxy(@subject, :foobar) {}
          end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
        end

        def creates_double_with_method_name(double)
          double.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
          double.argument_expectation.class.should == RR::Expectations::AnyArgumentExpectation

          @subject.foobar(:something).should == :original_value
        end

        def creates_stub_proxy_call_chain(creator)
          double = creator.foobar
          double.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
          double.argument_expectation.class.should == RR::Expectations::AnyArgumentExpectation

          @subject.foobar(1, 2).should == :original_value
        end
      end

      describe "#do_not_allow" do
        it_should_behave_like "RR::Adapters::RRMethods"

        before do
          @subject = Object.new
          class << @subject
            def foobar(*args)
              :original_value
            end
          end
        end

        it "returns a DoubleDefinitions::DoubleDefinitionCreator when passed no arguments" do
          do_not_allow.should be_instance_of(DoubleDefinitions::DoubleDefinitionCreator)
        end

        it "sets up the RR do_not_allow call chain" do
          creates_do_not_allow_call_chain(dont_allow(@subject))
          creates_do_not_allow_call_chain(rr_dont_allow(@subject))
          creates_do_not_allow_call_chain(dont_call(@subject))
          creates_do_not_allow_call_chain(rr_dont_call(@subject))
          creates_do_not_allow_call_chain(do_not_allow(@subject))
          creates_do_not_allow_call_chain(rr_do_not_allow(@subject))
          creates_do_not_allow_call_chain(dont_allow(@subject))
          creates_do_not_allow_call_chain(rr_dont_allow(@subject))
        end

        it "creates a mock Double for method when passed a second argument" do
          creates_double_with_method_name(dont_allow(@subject, :foobar))
          creates_double_with_method_name(rr_dont_allow(@subject, :foobar))
          creates_double_with_method_name(dont_call(@subject, :foobar))
          creates_double_with_method_name(rr_dont_call(@subject, :foobar))
          creates_double_with_method_name(do_not_allow(@subject, :foobar))
          creates_double_with_method_name(rr_do_not_allow(@subject, :foobar))
          creates_double_with_method_name(dont_allow(@subject, :foobar))
          creates_double_with_method_name(rr_dont_allow(@subject, :foobar))
        end

        it "raises error if passed a method name and a block" do
          lambda do
            do_not_allow(@subject, :foobar) {}
          end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
        end

        def creates_double_with_method_name(double)
          double.with(1, 2)
          double.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(0)
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          double.argument_expectation.expected_arguments.should == [1, 2]

          lambda do
            @subject.foobar(1, 2)
          end.should raise_error(Errors::TimesCalledError)
          reset
          nil
        end

        def creates_do_not_allow_call_chain(creator)
          double = creator.foobar(1, 2)
          double.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(0)
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          double.argument_expectation.expected_arguments.should == [1, 2]

          lambda do
            @subject.foobar(1, 2)
          end.should raise_error(Errors::TimesCalledError)
          reset
          nil
        end
      end
    end
  end
end
