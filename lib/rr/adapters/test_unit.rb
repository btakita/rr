module RR
  module Adapters
    module TestUnit
      include RRMethods
      def self.included(mod)
        RR.trim_backtrace = true
        mod.class_eval do
          alias_method :setup_without_rr, :setup
          def setup_with_rr
            setup_without_rr
            RR.reset
          end
          alias_method :setup, :setup_with_rr

          alias_method :teardown_without_rr, :teardown
          def teardown_with_rr
            RR.verify
            teardown_without_rr
          end
          alias_method :teardown, :teardown_with_rr
        end
      end

      def assert_received(subject, &block)
        block.call(received(subject)).call
      end
    end
  end
end
