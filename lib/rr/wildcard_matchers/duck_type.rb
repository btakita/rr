module RR
  module WildcardMatchers
    class DuckType
      attr_accessor :required_methods

      def initialize(*required_methods)
        @required_methods = required_methods
      end

      def wildcard_match?(other)
        return true if self == other
        required_methods.each do |m|
          return false unless other.respond_to?(m)
        end
        return true
      end

      def inspect
        formatted_required_methods = required_methods.collect do |method_name|
          method_name.inspect
        end.join(', ')
        "duck_type(#{formatted_required_methods})"
      end

      def ==(other)
        return false unless other.is_a?(self.class)
        self.required_methods == other.required_methods
      end
      alias_method :eql?, :==
    end
  end
end