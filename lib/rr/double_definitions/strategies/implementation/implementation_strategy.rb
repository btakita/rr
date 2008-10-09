module RR
  module DoubleDefinitions
    module Strategies
      module Implementation
        class ImplementationStrategy < Strategy
          class << self
            def register(*alias_method_names)
              DoubleDefinitionCreator.register_implementation_strategy_class(self)
              super
            end
          end
        end
      end
    end
  end
end