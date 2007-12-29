module RR
  module Expectations
    class AnyArgumentExpectation < ArgumentEqualityExpectation #:nodoc:
      def initialize
        super
      end

      def exact_match?(*arguments)
        false
      end

      def wildcard_match?(*arguments)
        true
      end

      def ==(other)
        other.is_a?(self.class)
      end
    end
  end
end