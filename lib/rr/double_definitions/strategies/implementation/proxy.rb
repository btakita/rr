module RR
  module DoubleDefinitions
    module Strategies
      module Implementation
        class Proxy < Strategy
          def name
            "proxy"
          end

          protected
          def do_call
            definition.after_call_block_callback_strategy
            definition.proxy
            definition.after_call(&handler) if handler
          end
        end
      end
    end
  end
end