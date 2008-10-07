module RR
  module DoubleDefinitions
    module Strategies
      module Implementation
        class Proxy < Strategy
          class << self
            def domain_name
              "proxy"
            end
          end

          protected
          def do_call
            definition.implemented_by_original_method
            definition.after_call(&handler) if handler
          end
        end
      end
    end
  end
end