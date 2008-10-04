module RR
  module DoubleDefinitions
    module Strategies
      module Verification
        class DontAllow < Strategy
          def name
            "dont_allow"
          end

          protected
          def do_call
            definition.never
            permissive_argument
            reimplementation
          end
        end
      end
    end
  end
end