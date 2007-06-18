module RR
  module Expectations
    class ArgumentEqualityExpectationError < RuntimeError
    end
    
    class ArgumentEqualityExpectation
      attr_reader :expected_arguments

      def initialize(*expected_arguments)
        @expected_arguments = expected_arguments
      end

      def exact_match?(*arguments)
        @expected_arguments == arguments
      end

      def wildcard_match?(*arguments)
        exact_match?(*arguments)
      end
    end
  end
end