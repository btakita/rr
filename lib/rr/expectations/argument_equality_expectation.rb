module RR
  module Expectations
    class ArgumentEqualityExpectationError < RuntimeError
    end
    
    class ArgumentEqualityExpectation < Expectation
      attr_reader :expected_arguments, :should_match_arguments

      def initialize(*expected_arguments)
        if expected_arguments.first.is_a?(Anything)
          @should_match_arguments = false
        else
          @should_match_arguments = true
          @expected_arguments = expected_arguments
        end
      end

      def verify_input(*arguments)
        return unless @should_match_arguments
        
        unless @expected_arguments.length == arguments.length
          raise(
            ArgumentEqualityExpectationError,
            "#{arguments.length} argument passed in. Expected #{@expected_arguments.length}."
          )
        end

        @expected_arguments.each_with_index do |expected_argument, i|
          unless expected_argument == arguments[i]
            raise ArgumentEqualityExpectationError, "#{arguments[i].inspect} is not #{expected_argument.inspect}"
          end
        end
      end

      def should_match_arguments?
        @should_match_arguments
      end

      class Anything; end
    end
  end
end