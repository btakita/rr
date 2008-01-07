require "spec/spec_helper"

module RR
  module Expectations
    describe TimesCalledExpectation, :shared => true do
      attr_reader :space, :object, :method_name, :double_insertion, :double, :expectation
      before do
        @space = Space.new
        @object = Object.new
        @method_name = :foobar
        @double_insertion = space.double_insertion(object, method_name)
        @double = space.double(double_insertion)
        double.with_any_args
      end

      def raises_expectation_error(&block)
        proc {block.call}.should raise_error(Errors::TimesCalledError)
      end
    end
  end
end
