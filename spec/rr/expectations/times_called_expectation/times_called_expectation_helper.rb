require "spec/spec_helper"

module RR
  module Expectations
    describe TimesCalledExpectation, :shared => true do
      attr_reader :space, :object, :method_name, :double_insertion, :scenario, :expectation
      before do
        @space = Space.new
        @object = Object.new
        @method_name = :foobar
        @double_insertion = space.double_insertion(object, method_name)
        @scenario = space.scenario(double_insertion)
        scenario.with_any_args
      end

      def raises_expectation_error(&block)
        proc {block.call}.should raise_error(Errors::TimesCalledError)
      end
    end
  end
end
