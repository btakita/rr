require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe DoubleInjection, "#verify" do
      it_should_behave_like "Swapped Space"
      attr_reader :space, :subject, :method_name, :double_injection
      before do
        @subject = Object.new
        @method_name = :foobar
        subject.methods.should_not include(method_name.to_s)
        @double_injection = space.double_injection(subject, method_name)
      end

      it "verifies each double was met" do
        double = Double.new(
          double_injection,
          DoubleDefinition.new(DoubleDefinitions::DoubleDefinitionCreator.new, subject)
        )
        double_injection.register_double double

        double.definition.with(1).once.returns {nil}
        lambda {double_injection.verify}.should raise_error(Errors::TimesCalledError)
        subject.foobar(1)
        lambda {double_injection.verify}.should_not raise_error
      end
    end    
  end
end
