module RR
  module DoubleDefinitions
    module Strategies
      module Verification
        class DontAllow < Strategy
          class << self
            def domain_name
              "dont_allow"
            end
          end
          DoubleDefinitionCreator.register_verification_strategy_class(self)
          DoubleDefinitionCreator.class_eval do
            alias_method :do_not_allow, :dont_allow
            alias_method :dont_call, :dont_allow
            alias_method :do_not_call, :dont_allow
            
            alias_method :do_not_allow!, :dont_allow!
            alias_method :dont_call!, :dont_allow!
            alias_method :do_not_call!, :dont_allow!
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