module RR
  module DoubleDefinitions
    module Strategies
      module Implementation
        class Reimplementation < ImplementationStrategy
          class << self
            def domain_name
              "reimplementation"
            end
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