module RR
  module DoubleDefinitions
    module Strategies
      module MethodSignatureVerification
        class MethodSignatureVerificationStrategy < Strategy
          class << self
            def register_self_at_double_definition_creator(domain_name)
              DoubleDefinitionCreator.register_method_signature_verification_strategy_class(self, domain_name)
            end
          end
        end
      end
    end
  end
end