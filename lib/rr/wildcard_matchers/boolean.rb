module RR
  module WildcardMatchers
    class Boolean
      def wildcard_match?(other)
        self == other || is_a_boolean?(other)
      end

      def ==(other)
        other.is_a?(self.class)
      end
      alias_method :eql?, :==

      def inspect
        'boolean'
      end

      protected
      def is_a_boolean?(subject)
        subject.is_a?(TrueClass) || subject.is_a?(FalseClass)
      end
    end
  end
end