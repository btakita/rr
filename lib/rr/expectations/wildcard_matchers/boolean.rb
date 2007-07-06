module RR
  module Expectations
    module WildcardMatchers
      module BooleanTracer
      end
      class ::TrueClass
        include BooleanTracer
      end
      class ::FalseClass
        include BooleanTracer
      end
      
      class Boolean < IsA
        def initialize
          @klass = BooleanTracer
        end
      end
    end
  end
end