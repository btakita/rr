module RR
  module Adapters
    module Rspec
      def self.included(mod)
        patterns = ::Spec::Runner::QuietBacktraceTweaker::IGNORE_PATTERNS
        unless patterns.include?(RR::Errors::BACKTRACE_IDENTIFIER)
          patterns.push(RR::Errors::BACKTRACE_IDENTIFIER)
        end
      end

      include RRMethods
      def setup_mocks_for_rspec
        RR.reset
      end
      def verify_mocks_for_rspec
        RR.verify
      end
      def teardown_mocks_for_rspec
        RR.reset
      end
    end
  end
end
