# require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Expectations
    describe TimesCalledExpectation, :shared => true do
      attr_reader :space, :subject, :method_name, :double_injection, :double, :double_definition
      before do
        @space = Space.new
        @subject = Object.new
        @method_name = :foobar
        @double_injection = space.double_injection(subject, method_name)
        @double_definition = DoubleDefinitions::DoubleDefinition.new(
          DoubleDefinitions::DoubleDefinitionCreator.new,
          subject
        )
        @double = new_double(double_injection)
        double.with_any_args
      end

      def raises_expectation_error(&block)
        lambda {block.call}.should raise_error(Errors::TimesCalledError)
      end
    end
  end
end
