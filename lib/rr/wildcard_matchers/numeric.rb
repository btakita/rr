module RR
  module WildcardMatchers
    class Numeric < IsA
      def initialize
        @klass = ::Numeric
      end
    end
  end
end