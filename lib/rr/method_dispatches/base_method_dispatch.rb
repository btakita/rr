module RR
  module MethodDispatches
    class BaseMethodDispatch
      include Space::Reader

      attr_reader :double_injection, :args, :block, :double

      def initialize(double_injection, args, block)
        @double_injection, @args, @block = double_injection, args, block
        @double = find_double_to_attempt
      end

      def call
        raise NotImplementedError
      end
    end
  end
end
