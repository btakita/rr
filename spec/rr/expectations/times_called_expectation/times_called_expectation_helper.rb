# require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Expectations
    describe TimesCalledExpectation, :shared => true do
      attr_reader :space, :object, :method_name, :double_injection, :double, :expectation
      before do
        @space = Space.new
        @object = Object.new
        @method_name = :foobar
        @double_injection = space.double_injection(object, method_name)
        @double = Double.new(double_injection)
        double.with_any_args
      end

      def raises_expectation_error(&block)
        lambda {block.call}.should raise_error(Errors::TimesCalledError)
      end
    end
  end
end
