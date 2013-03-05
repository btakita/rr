module RR
  module Adapters
    module RSpec2
      def self.included(mod)
        patterns = RSpec.configuration.backtrace_clean_patterns
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

      def have_received(method = nil)
        RR::Adapters::Rspec::InvocationMatcher.new(method)
      end
    end
  end
end
