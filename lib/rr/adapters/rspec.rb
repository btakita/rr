module RR
  module Adapters
    module Rspec
      def self.included(mod)
        patterns = ::Spec::Runner::QuietBacktraceTweaker::IGNORE_PATTERNS
        patterns.push(RR::Errors::BACKTRACE_IDENTIFIER)
      end

      include RR::Extensions::InstanceMethods
      def setup_mocks_for_rspec
        rr_reset
      end
      def verify_mocks_for_rspec
        rr_verify
      end
      def teardown_mocks_for_rspec
        rr_reset
      end
    end
  end
end
