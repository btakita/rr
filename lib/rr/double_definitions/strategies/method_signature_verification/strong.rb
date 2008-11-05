module RR
  module DoubleDefinitions
    module Strategies
      module MethodSignatureVerification   
        class Strong < MethodSignatureVerificationStrategy
          register("strong")

          protected
          def do_call
            definition.verify_method_signature
          end
        end
      end
    end
  end
end