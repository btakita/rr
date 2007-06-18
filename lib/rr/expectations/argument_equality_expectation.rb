module RR
  module Expectations
    class ArgumentEqualityExpectationError < RuntimeError
    end
    
    class ArgumentEqualityExpectation
      attr_reader :expected_arguments, :should_match_arguments

      def initialize(*expected_arguments)
        if expected_arguments.first.is_a?(Anything)
          @should_match_arguments = false
        else
          @should_match_arguments = true
          @expected_arguments = expected_arguments
        end
      end

      def exact_match?(*arguments)
        @expected_arguments == arguments
      end

      def wildcard_match?(*arguments)
        return true unless @should_match_arguments
        exact_match?(*arguments)
      end

      def should_match_arguments?
        @should_match_arguments
      end

      class Anything; end
    end
  end
end