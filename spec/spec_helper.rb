dir = File.dirname(__FILE__)
require "#{dir}/environment_fixture_setup"
require "#{dir}/rr/expectations/times_called_expectation/times_called_expectation_helper"
require "#{dir}/rr/adapters/rr_methods_spec_helper"

Spec::Runner.configure do |config|
  config.mock_with RR::Adapters::Rspec
end

describe "Swapped Space", :shared => true do
  attr_reader :space, :original_space
  before do
    @original_space = RR::Space.instance
    RR::Space.instance = RR::Space.new
    @space = RR::Space.instance
  end

  after(:each) do
    RR::Space.instance = @original_space
  end
end

module Spec::Example::ExampleMethods
  def new_double(
    double_injection=double_injection,
    double_definition=RR::DoubleDefinitions::DoubleDefinition.new(creator = RR::DoubleDefinitions::DoubleDefinitionCreator.new, subject).with_any_args.any_number_of_times
  )
    RR::Double.new(
      double_injection,
      double_definition
    )
  end
end

module Spec::Example::ExampleGroupMethods
  def macro(name, &implementation)
    (class << self; self; end).class_eval do
      define_method(name, &implementation)
    end
  end

  define_method("normal strategy definition") do
    describe "strategy definition" do
      attr_reader :strategy_method_name

      context "when passed a subject" do
        it "returns a DoubleDefinitionCreatorProxy" do
          double = call_strategy(subject).foobar
          double.should be_instance_of(RR::DoubleDefinitions::DoubleDefinition)
        end
      end

      context "when passed a method name and a definition_eval_block" do
        it "raises an ArgumentError" do
          lambda do
            call_strategy(subject, :foobar) {}
          end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
        end
      end
    end
  end

  define_method("! strategy definition") do
    describe "strategy definition" do
      attr_reader :strategy_method_name

      context "when not passed a method_name argument" do
        it "returns a DoubleDefinitionCreatorProxy" do
          call_strategy.should respond_to(:__subject__)
        end

        context "when passed a definition_eval_block argument" do
          it "calls the definition_eval_block and passes in the DoubleDefinitionCreatorProxy" do
            passed_in_proxy = nil
            proxy = call_strategy do |proxy|
              passed_in_proxy = proxy
            end

            passed_in_proxy.should == proxy
          end
        end
      end

      context "when passed a method_name argument" do
        it "returns a DoubleDefinition" do
          double_definition = call_strategy(:foobar)
          double_definition.class.should == RR::DoubleDefinitions::DoubleDefinition
        end

        describe "the returned DoubleDefinition" do
          it "has #subject set to an anonymous Object" do
            double_definition = call_strategy(:foobar)
            double_definition.subject.class.should == Object
          end
        end
      end

      context "when passed a method name and a definition_eval_block" do
        it "raises an ArgumentError" do
          lambda do
            call_strategy(:foobar) {}
          end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
        end
      end
    end
  end
end