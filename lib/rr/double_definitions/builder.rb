module RR
  module DoubleDefinitions
    class Builder #:nodoc:
      attr_reader :creator, :subject, :method_name, :args, :handler, :definition, :verification_strategy, :implementation_strategy, :scope_strategy
      include Errors
      include Space::Reader

      def initialize(creator)
        @creator = creator
        @using_instance_of_strategy = nil
        @verification_strategy = nil
        @implementation_strategy = Strategies::Implementation::Reimplementation.new
        @scope_strategy = Strategies::Scope::Instance.new
      end

      def build(subject, method_name, args, handler)
        @subject, @method_name, @args, @handler = subject, method_name, args, handler
        @definition = DoubleDefinition.new(creator, subject)
        verification_strategy ? verification_strategy.call(definition, method_name, args, handler) : no_strategy_error
        implementation_strategy.call(definition, method_name, args, handler)
        scope_strategy.call(definition, method_name, args, handler)
        definition
      end

      def verification_strategy=(verification_strategy)
        verify_no_verification_strategy
        verify_not_proxy_and_dont_allow(verification_strategy, implementation_strategy)
        @verification_strategy = verification_strategy
        verification_strategy
      end

      def implementation_strategy=(implementation_strategy)
        verify_not_proxy_and_dont_allow(verification_strategy, implementation_strategy)
        @implementation_strategy = implementation_strategy
      end

      def scope_strategy=(scope_strategy)
        verify_not_proxy_and_dont_allow(verification_strategy, implementation_strategy)
        @scope_strategy = scope_strategy
      end

      protected
      def verify_no_verification_strategy
        strategy_already_defined_error if verification_strategy
      end

      def strategy_already_defined_error
        raise(
          DoubleDefinitionError,
          "This Double already has a #{verification_strategy.name} strategy"
        )
      end

      def verify_not_proxy_and_dont_allow(verification_strategy, implementation_strategy)
        proxy_when_dont_allow_error if
          verification_strategy.is_a?(Strategies::Verification::DontAllow) &&
          implementation_strategy.is_a?(Strategies::Implementation::Proxy)
      end

      def proxy_when_dont_allow_error
        raise(
          DoubleDefinitionError,
          "Doubles cannot be proxied when using dont_allow strategy"
        )
      end

      def no_strategy_error
        raise(
          DoubleDefinitionError,
          "This Double has no strategy"
        )
      end
    end
  end
end
