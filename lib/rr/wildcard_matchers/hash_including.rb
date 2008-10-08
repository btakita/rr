module RR
  module WildcardMatchers
    class HashIncluding
      attr_reader :expected_hash

      def initialize(expected_hash)
        @expected_hash = expected_hash.clone
      end

      def wildcard_match?(other)
        return true if self == other
        expected_hash.each_pair do |key, value|
          return false unless other.has_key?(key) && other[key] == expected_hash[key]
        end
        return true
      end

      def inspect
        "hash_including(#{expected_hash.inspect})"
      end

      def ==(other)
        return false unless other.is_a?(self.class)
        self.expected_hash == other.expected_hash
      end
      alias_method :eql?, :==
    end
  end
end