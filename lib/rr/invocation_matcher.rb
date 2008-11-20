module RR
  class InvocationMatcher
    include Space::Reader
    attr_reader :failure_message, :spy_verification_proxy, :verification

    def initialize(method = nil)
      @spy_verification_proxy = RR::SpyVerificationProxy.new(nil)
      if method
        define_spy_verification(method)
      end
    end

    def define_spy_verification(method, *args)
      @verification = spy_verification_proxy.method_missing(method, *args)
    end

    def method_missing(method_name, *args, &block)
      if verification
        verification.send(method_name, *args)
      else
        define_spy_verification(method_name, *args)
      end
      self
    end

    def matches?(subject)
      verification.subject = subject
      space.recorded_calls.matches?(verification)
    end
  end
end
