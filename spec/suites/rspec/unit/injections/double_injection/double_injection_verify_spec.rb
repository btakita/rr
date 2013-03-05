require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Injections
    describe DoubleInjection, "#verify" do
      subject { Object.new }

      include_examples "Swapped Space"

      attr_reader :method_name, :double_injection

      before do
        @method_name = :foobar
        subject.methods.should_not include(method_name.to_s)
        @double_injection = ::RR::Injections::DoubleInjection.find_or_create_by_subject(subject, method_name)
      end

      it "verifies each double was met" do
        double = RR::Double.new(
          double_injection,
          RR::DoubleDefinitions::DoubleDefinition.new(RR::DoubleDefinitions::DoubleDefinitionCreate.new)
        )
        double_injection.register_double double

        double.definition.with(1).once.returns {nil}
        expect { double_injection.verify }.to raise_error(RR::Errors::TimesCalledError)
        subject.foobar(1)
        expect { double_injection.verify }.to_not raise_error
      end
    end
  end
end
