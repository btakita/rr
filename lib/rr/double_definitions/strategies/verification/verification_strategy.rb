module RR
  module DoubleDefinitions
    module Strategies
      module Verification
        class VerificationStrategy < Strategy
          class << self
            def register(*alias_method_names)
              DoubleDefinitionCreator.register_verification_strategy_class(self)
              super
            end
          end
        end
      end
    end
  end
end