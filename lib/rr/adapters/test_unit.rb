require "spec/mocks"
require "rr"

module RR
  module Adapters
    module TestUnit
      include RR::Extensions::DoubleMethods
      def self.included(mod)
        mod.class_eval do
          alias_method :setup_without_rr, :setup
          def setup_with_rr
            setup_without_rr
            RR::Space.instance.reset_doubles
          end
          alias_method :setup, :setup_with_rr

          alias_method :teardown_without_rr, :teardown
          def teardown_with_rr
            RR::Space.instance.verify_doubles
            teardown_without_rr
          end
          alias_method :teardown, :teardown_with_rr
        end
      end
    end
  end
end
