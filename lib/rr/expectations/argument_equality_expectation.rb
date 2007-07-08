module RR
  module Expectations
    class ArgumentEqualityError
      attr_reader :expected_arguments

      def initialize(*expected_arguments)
        @expected_arguments = expected_arguments
      end

      def exact_match?(*arguments)
        @expected_arguments == arguments
      end

      def wildcard_match?(*arguments)
        return false unless arguments.length == @expected_arguments.length
        arguments.each_with_index do |arg, index|
          expected_argument = @expected_arguments[index]
          if expected_argument.respond_to?(:wildcard_match?)
            return false unless expected_argument.wildcard_match?(arg)
          else
            return false unless expected_argument == arg
          end
        end
        return true
      end

      def ==(other)
        @expected_arguments == other.expected_arguments
      end
    end
  end
end