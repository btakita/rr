module RR
  module DoubleDefinitions
    module Strategies
      module Implementation
        class Reimplementation < Strategy
          def name
            "reimplementation"
          end

          protected
          def do_call
            reimplementation
          end
        end
      end
    end
  end
end