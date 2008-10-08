module RR
  module DoubleDefinitions
    module Strategies
      module Scope
        class ScopeStrategy < Strategy
          class << self
            def register(*alias_method_names)
              DoubleDefinitionCreator.register_scope_strategy_class(self)
              super
            end
          end
        end
      end
    end
  end
end