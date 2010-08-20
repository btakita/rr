module RR
  module DoubleDefinitions
    module Strategies
      module Verification
        class VerificationStrategy < Strategy
          extend(Module.new do
            def register_self_at_double_definition_create(strategy_method_name)
              DoubleDefinitionCreate.register_verification_strategy_class(self, strategy_method_name)
            end
          end)
        end
      end
    end
  end
end