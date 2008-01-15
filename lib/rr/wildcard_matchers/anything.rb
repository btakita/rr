module RR
  module WildcardMatchers
    class Anything
      def wildcard_match?(other)
        true
      end

      def ==(other)
        other.is_a?(self.class)
      end

      def inspect
        'anything'
      end
    end
  end
end