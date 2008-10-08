module RR
  module DoubleDefinitions
    module Strategies
      module Verification
        class Mock < Strategy
          class << self
            def domain_name
              "mock"
            end
          end
          DoubleDefinitionCreator.register_verification_strategy_class(self)

          protected
          def do_call
            definition.with(*args).once
          end
        end
      end
    end
  end
end