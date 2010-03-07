module RR
  module DoubleDefinitions
    module Strategies
      module Implementation
        class ImplementationStrategy < Strategy
          class << self
            def register_self_at_double_definition_create(strategy_method_name)
              DoubleDefinitionCreate.register_implementation_strategy_class(self, strategy_method_name)
            end
          end
        end
      end
    end
  end
end