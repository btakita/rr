module RR
  module WildcardMatchers
    class Satisfy
      attr_reader :expectation_proc

      def initialize(expectation_proc)
        @expectation_proc = expectation_proc
      end

      def wildcard_match?(other)
        return true if self == other
        !!expectation_proc.call(other)
      end

      def inspect
        "satisfy {block}"
      end

      def ==(other)
        return false unless other.is_a?(self.class)
        self.expectation_proc == other.expectation_proc
      end
      alias_method :eql?, :==
    end
  end
end