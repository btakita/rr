module RR
  class InvocationMatcher < SpyVerificationProxy
    attr_reader :failure_message

    def initialize(method = nil)
      method_missing(method) if method
    end

    def matches?(subject)
      @verification.subject = subject
      RR::Space.instance.recorded_calls.matches?(@verification)
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
