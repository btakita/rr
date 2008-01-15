module RR
  module WildcardMatchers
    class Numeric < IsA
      def initialize
        @klass = ::Numeric
      end

      def inspect
        'numeric'
      end
    end
  end
end