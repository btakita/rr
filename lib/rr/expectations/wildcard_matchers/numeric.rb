module RR
  module Expectations
    module WildcardMatchers
      class Numeric < IsA
        def initialize
          @klass = ::Numeric
        end
      end
    end
  end
end