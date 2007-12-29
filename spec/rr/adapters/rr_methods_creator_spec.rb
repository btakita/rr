require "spec/spec_helper"

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

        it "returns a ScenarioCreator when passed no arguments" do
          mock.should be_instance_of(ScenarioCreator)
        end

        it "sets up the RR mock call chain" do
          creates_mock_call_chain(mock(@subject))
        end

        it "#rr_mock sets up the RR mock call chain" do
          creates_mock_call_chain(rr_mock(@subject))
        end

        it "creates a mock Scenario for method when passed a second argument" do
          creates_scenario_with_method_name(mock(@subject, :foobar))
        end

        it "creates a mock Scenario for method when passed a second argument with rr_mock" do
          creates_scenario_with_method_name(rr_mock(@subject, :foobar))
        end

        it "raises error if passed a method name and a block" do
          proc do
            mock(@object, :foobar) {}
          end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
        end

        def creates_scenario_with_method_name(scenario)
          scenario.with(1, 2) {:baz}
          scenario.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
          scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          scenario.argument_expectation.expected_arguments.should == [1, 2]

          @subject.foobar(1, 2).should == :baz
        end

        def creates_mock_call_chain(creator)
          scenario = creator.foobar(1, 2) {:baz}
          scenario.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
          scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          scenario.argument_expectation.expected_arguments.should == [1, 2]

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

        it "returns a ScenarioCreator when passed no arguments" do
          stub.should be_instance_of(ScenarioCreator)
        end

        it "sets up the RR stub call chain" do
          creates_stub_call_chain(stub(@subject))
        end

        it "#rr_stub sets up the RR stub call chain" do
          creates_stub_call_chain(rr_stub(@subject))
        end

        it "creates a stub Scenario for method when passed a second argument" do
          creates_scenario_with_method_name(stub(@subject, :foobar))
        end

        it "#rr_stub creates a stub Scenario for method when passed a second argument" do
          creates_scenario_with_method_name(rr_stub(@subject, :foobar))
        end

        it "raises error if passed a method name and a block" do
          proc do
            stub(@object, :foobar) {}
          end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
        end

        def creates_scenario_with_method_name(scenario)
          scenario.with(1, 2) {:baz}
          scenario.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
          scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          @subject.foobar(1, 2).should == :baz
        end

        def creates_stub_call_chain(creator)
          scenario = creator.foobar(1, 2) {:baz}
          scenario.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
          scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
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

        it "#proxy returns a ScenarioCreator when passed no arguments" do
          proxy.should be_instance_of(ScenarioCreator)
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

        it "#proxy creates a mock Scenario for method when passed a second argument" do
          creates_scenario_with_method_name(mock.proxy(@subject, :foobar))
        end

        it "#rr_proxy creates a mock Scenario for method when passed a second argument with rr_mock" do
          creates_scenario_with_method_name(rr_proxy.mock(@subject, :foobar))
        end

        it "#mock_proxy creates a mock Scenario for method when passed a second argument" do
          creates_scenario_with_method_name(mock.proxy(@subject, :foobar))
        end

        it "#rr_mock_proxy creates a mock Scenario for method when passed a second argument with rr_mock" do
          creates_scenario_with_method_name(rr_mock.proxy(@subject, :foobar))
        end

        it "raises error if passed a method name and a block" do
          proc do
            mock.proxy(@object, :foobar) {}
          end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
        end

        def creates_scenario_with_method_name(scenario)
          scenario.with(1, 2)
          scenario.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
          scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          scenario.argument_expectation.expected_arguments.should == [1, 2]

          @subject.foobar(1, 2).should == :original_value
        end

        def creates_mock_proxy_call_chain(creator)
          scenario = creator.foobar(1, 2)
          scenario.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
          scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          scenario.argument_expectation.expected_arguments.should == [1, 2]

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

        it "returns a ScenarioCreator when passed no arguments" do
          stub.proxy.should be_instance_of(ScenarioCreator)
        end

        it "sets up the RR proxy call chain" do
          creates_stub_proxy_call_chain(stub.proxy(@subject))
        end

        it "sets up the RR proxy call chain" do
          creates_stub_proxy_call_chain(rr_stub.proxy(@subject))
        end

        it "#stub.proxy creates a stub Scenario for method when passed a second argument" do
          creates_scenario_with_method_name(stub.proxy(@subject, :foobar))
        end

        it "#rr_stub.proxy creates a stub Scenario for method when passed a second argument with rr_stub" do
          creates_scenario_with_method_name(rr_stub.proxy(@subject, :foobar))
        end

        it "raises error if passed a method name and a block" do
          proc do
            stub.proxy(@object, :foobar) {}
          end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
        end

        def creates_scenario_with_method_name(scenario)
          scenario.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
          scenario.argument_expectation.class.should == RR::Expectations::AnyArgumentExpectation

          @subject.foobar(:something).should == :original_value
        end

        def creates_stub_proxy_call_chain(creator)
          scenario = creator.foobar
          scenario.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
          scenario.argument_expectation.class.should == RR::Expectations::AnyArgumentExpectation

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

        it "returns a ScenarioCreator when passed no arguments" do
          do_not_allow.should be_instance_of(ScenarioCreator)
        end

        it "sets up the RR do_not_allow call chain" do
          creates_do_not_allow_call_chain(do_not_call(@subject))
          creates_do_not_allow_call_chain(rr_do_not_call(@subject))
          creates_do_not_allow_call_chain(dont_call(@subject))
          creates_do_not_allow_call_chain(rr_dont_call(@subject))
          creates_do_not_allow_call_chain(do_not_allow(@subject))
          creates_do_not_allow_call_chain(rr_do_not_allow(@subject))
          creates_do_not_allow_call_chain(dont_allow(@subject))
          creates_do_not_allow_call_chain(rr_dont_allow(@subject))
        end

        it "creates a mock Scenario for method when passed a second argument" do
          creates_scenario_with_method_name(do_not_call(@subject, :foobar))
          creates_scenario_with_method_name(rr_do_not_call(@subject, :foobar))
          creates_scenario_with_method_name(dont_call(@subject, :foobar))
          creates_scenario_with_method_name(rr_dont_call(@subject, :foobar))
          creates_scenario_with_method_name(do_not_allow(@subject, :foobar))
          creates_scenario_with_method_name(rr_do_not_allow(@subject, :foobar))
          creates_scenario_with_method_name(dont_allow(@subject, :foobar))
          creates_scenario_with_method_name(rr_dont_allow(@subject, :foobar))
        end

        it "raises error if passed a method name and a block" do
          proc do
            do_not_allow(@object, :foobar) {}
          end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
        end

        def creates_scenario_with_method_name(scenario)
          scenario.with(1, 2)
          scenario.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(0)
          scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          scenario.argument_expectation.expected_arguments.should == [1, 2]

          proc do
            @subject.foobar(1, 2)
          end.should raise_error(Errors::TimesCalledError)
          reset
          nil
        end

        def creates_do_not_allow_call_chain(creator)
          scenario = creator.foobar(1, 2)
          scenario.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(0)
          scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          scenario.argument_expectation.expected_arguments.should == [1, 2]

          proc do
            @subject.foobar(1, 2)
          end.should raise_error(Errors::TimesCalledError)
          reset
          nil
        end
      end

      describe ScenarioCreator, "#instance_of and #mock" do
        before do
          @klass = Class.new
        end

        it "returns a ScenarioCreator when passed no arguments" do
          instance_of.instance_of.should be_instance_of(ScenarioCreator)
        end

        it "sets up the RR instance_of call chain" do
          creates_instance_of_call_chain(instance_of.mock(@klass))
        end

        it "#rr_instance_of sets up the RR instance_of call chain" do
          creates_instance_of_call_chain(rr_instance_of.mock(@klass))
        end

        it "creates a instance_of Scenario for method when passed a second argument" do
          creates_scenario_with_method_name(instance_of.mock(@klass, :foobar))
        end

        it "creates a instance_of Scenario for method when passed a second argument with rr_instance_of" do
          creates_scenario_with_method_name(rr_instance_of.mock(@klass, :foobar))
        end

        it "raises error if passed a method name and a block" do
          proc do
            instance_of.mock(@klass, :foobar) {}
          end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
        end

        def creates_scenario_with_method_name(scenario)
          scenario.with(1, 2) {:baz}
          scenario.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
          scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          scenario.argument_expectation.expected_arguments.should == [1, 2]

          @klass.new.foobar(1, 2).should == :baz
        end

        def creates_instance_of_call_chain(creator)
          scenario = creator.foobar(1, 2) {:baz}
          scenario.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
          scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          scenario.argument_expectation.expected_arguments.should == [1, 2]

          @klass.new.foobar(1, 2).should == :baz
        end
      end
    end
  end
end
