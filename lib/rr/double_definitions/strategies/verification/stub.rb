module RR
  module DoubleDefinitions
    module Strategies
      module Verification
        class Stub < Strategy
          def name
            "stub"
          end

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