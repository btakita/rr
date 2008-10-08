module RR
  module DoubleDefinitions
    module Strategies
      module Scope
        class Instance < ScopeStrategy
          protected
          def do_call
            double_injection = space.double_injection(subject, method_name)
            Double.new(double_injection, definition)
          end
        end
      end
    end
  end
end