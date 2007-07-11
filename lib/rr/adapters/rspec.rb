patterns = ::Spec::Runner::QuietBacktraceTweaker::IGNORE_PATTERNS
patterns.push(RR::Errors::BACKTRACE_IDENTIFIER)

module RR
  module Adapters
    module Rspec
      include RR::Extensions::DoubleMethods
      def setup_mocks_for_rspec
        RR::Space.instance.reset_scenarios
      end
      def verify_mocks_for_rspec
        RR::Space.instance.verify_scenarios
      end
      def teardown_mocks_for_rspec
        RR::Space.instance.reset_scenarios
      end
    end
  end
end
