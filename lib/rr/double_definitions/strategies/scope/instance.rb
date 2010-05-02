module RR
  module DoubleDefinitions
    module Strategies
      module Scope
        class Instance < ScopeStrategy
          protected
          def do_call
            double_injection = Injections::DoubleInjection.find_or_create(subject, method_name)
            Double.new(double_injection, definition)
          end
        end
      end
    end
  end
end