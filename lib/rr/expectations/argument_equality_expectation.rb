module RR
  module Expectations
    class ArgumentEqualityExpectationError < RuntimeError
    end
    
    class ArgumentEqualityExpectation < Expectation
      def initialize(*expected_arguments)
        @expected_arguments = expected_arguments
      end

      def verify_input(*arguments)
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
    end
  end
end