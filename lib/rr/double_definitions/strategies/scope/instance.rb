module RR
  module DoubleDefinitions
    module Strategies
      module Scope
        class Instance < ScopeStrategy
          protected
          def do_call
            double_injection = Injections::DoubleInjection.create(subject, method_name)
            Double.new(double_injection, definition)
          end
        end
      end
    end
  end
end