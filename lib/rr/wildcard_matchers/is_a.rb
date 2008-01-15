module RR
  module WildcardMatchers
    class IsA
      attr_reader :klass

      def initialize(klass)
        @klass = klass
      end

      def wildcard_match?(other)
        self == other || other.is_a?(klass)
      end

      def inspect
        "is_a(#{klass})"
      end

      def ==(other)
        return false unless other.is_a?(self.class)
        self.klass == other.klass
      end
      alias_method :eql?, :==
    end
  end
end