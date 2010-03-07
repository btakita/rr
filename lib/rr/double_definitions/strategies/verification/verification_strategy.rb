module RR
  module DoubleDefinitions
    module Strategies
      module Verification
        class VerificationStrategy < Strategy
          class << self
            def register_self_at_double_definition_create(domain_name)
              DoubleDefinitionCreate.register_verification_strategy_class(self, domain_name)
            end
          end
        end
      end
    end
  end
end