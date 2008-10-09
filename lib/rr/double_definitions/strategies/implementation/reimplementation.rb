module RR
  module DoubleDefinitions
    module Strategies
      module Implementation
        class Reimplementation < ImplementationStrategy
          protected
          def do_call
            reimplementation
          end
        end
      end
    end
  end
end