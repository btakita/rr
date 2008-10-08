module RR
  module DoubleDefinitions
    module Strategies
      module Implementation
        class Proxy < Strategy
          class << self
            def domain_name
              "proxy"
            end
          end
          DoubleDefinitionCreator.register_implementation_strategy_class(self)
          DoubleDefinitionCreator.class_eval do
            alias_method :probe, :proxy
          end

          protected
          def do_call
            definition.implemented_by_original_method
            definition.after_call(&handler) if handler
          end
        end
      end
    end
  end
end