module RR
  module DoubleDefinitions
    module Strategies
      module Implementation
        class StronglyTypedReimplementation < Reimplementation
          register("strong")

          protected
          def do_call
            super
            definition.verify_method_signature
          end
        end
      end
    end
  end
end