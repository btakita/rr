module RR
  module Adapters
    module TestUnit
      include RR::Extensions::InstanceMethods
      def self.included(mod)
        RR::Space.trim_backtrace = true
        mod.class_eval do
          alias_method :setup_without_rr, :setup
          def setup_with_rr
            setup_without_rr
            rr_reset
          end
          alias_method :setup, :setup_with_rr

          alias_method :teardown_without_rr, :teardown
          def teardown_with_rr
            rr_verify
            teardown_without_rr
          end
          alias_method :teardown, :teardown_with_rr
        end
      end
    end
  end
end
