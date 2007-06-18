module RR
  module Expectations
    class AnyArgumentExpectation
      def exact_match?(*arguments)
        false
      end

      def wildcard_match?(*arguments)
        true
      end

      def ==(other)
        self.class == other.class
      end
    end
  end
end