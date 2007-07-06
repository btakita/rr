module RR
  module Expectations
    module WildcardMatchers
      class IsA
        attr_reader :klass
        
        def initialize(klass)
          @klass = klass
        end
        
        def wildcard_match?(other)
          self == other || other.is_a?(klass)
        end

        def ==(other)
          return false unless other.is_a?(self.class)
          self.klass == other.klass
        end
      end
    end
  end
end