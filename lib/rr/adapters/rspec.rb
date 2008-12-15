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

      def have_received(method = nil)
        InvocationMatcher.new(method)
      end

      class InvocationMatcher < SpyVerificationProxy
        attr_reader :failure_message
 
        def initialize(method = nil)
          method_missing(method) if method
        end

        def matches?(subject)
          @verification.subject = subject
          RR::Space.instance.recorded_calls.match_error(@verification) ? false : true
        end

        def nil?
          false
        end

        def method_missing(method_name, *args, &block)
          if @verification
            @verification.send(method_name, *args)
          else
            @verification = super
          end
          self
        end
      end
    end
  end
end
