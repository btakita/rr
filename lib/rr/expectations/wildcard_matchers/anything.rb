module RR
  module Expectations
    module WildcardMatchers
      class Anything
        def wildcard_match?(other)
          true
        end

        def ==(other)
          other.is_a?(self.class)
        end
      end
    end
  end
end