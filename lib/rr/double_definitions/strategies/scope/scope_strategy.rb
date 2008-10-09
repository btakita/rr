module RR
  module DoubleDefinitions
    module Strategies
      module Scope
        class ScopeStrategy < Strategy
          class << self
            def register_self_at_external_object(domain_name)
              DoubleDefinitionCreator.register_scope_strategy_class(self, domain_name)
            end
          end
        end
      end
    end
  end
end