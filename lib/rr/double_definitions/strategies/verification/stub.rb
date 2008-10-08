module RR
  module DoubleDefinitions
    module Strategies
      module Verification
        class Stub < Strategy
          class << self
            def domain_name
              "stub"
            end
          end
          DoubleDefinitionCreator.register_verification_strategy_class(self)

          protected
          def do_call
            definition.any_number_of_times
            permissive_argument
          end
        end
      end
    end
  end
end