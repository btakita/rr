module RR
  module DoubleDefinitions
    class DoubleDefinitionCreate # :nodoc
      attr_reader :subject, 
                  :verification_strategy,
                  :implementation_strategy, 
                  :scope_strategy
      NO_SUBJECT = Object.new

      include Space::Reader

      def initialize
        @verification_strategy = nil
        @implementation_strategy = Strategies::Implementation::Reimplementation.new(self)
        @scope_strategy = Strategies::Scope::Instance.new(self)
      end

      def call(method_name, *args, &handler)
        raise DoubleDefinitionCreateError if no_subject?
        definition = DoubleDefinition.new(self)
        verification_strategy || no_strategy_error
        verification_strategy.call(definition, method_name, args, handler)
        implementation_strategy.call(definition, method_name, args, handler)
        scope_strategy.call(definition, method_name, args, handler)
        definition
      end
      
      def root_subject
        subject
      end
      
      def method_name
        @verification_strategy.method_name
      end
      
      module StrategySetupMethods
        def no_subject?
          subject.__id__ === NO_SUBJECT.__id__
        end

        protected
        def add_verification_strategy(verification_strategy_class, subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
          add_strategy(subject, method_name, definition_eval_block) do
            self.verification_strategy = verification_strategy_class.new(self)
          end
        end

        def add_implementation_strategy(implementation_strategy_class, subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
          add_strategy(subject, method_name, definition_eval_block) do
            self.implementation_strategy = implementation_strategy_class.new(self)
          end
        end

        def add_scope_strategy(scope_strategy_class, subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
          add_strategy(subject, method_name, definition_eval_block) do
            self.scope_strategy = scope_strategy_class.new(self)
          end
        end

        def add_strategy(subject, method_name, definition_eval_block)
          if method_name && definition_eval_block
            raise ArgumentError, "Cannot pass in a method name and a block"
          end
          @subject = subject
          yield
          # TODO: Allow hash argument to simulate a Struct.
          if no_subject?
            self
          elsif method_name
            # TODO: Pass in arguments.
            call(method_name)
          else
            DoubleDefinitionCreateBlankSlate.new(self, &definition_eval_block)
          end
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

        def verify_no_verification_strategy
          strategy_already_defined_error if verification_strategy
        end

        def strategy_already_defined_error
          raise(
            Errors::DoubleDefinitionError,
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
            Errors::DoubleDefinitionError,
            "Doubles cannot be proxied when using dont_allow strategy"
          )
        end

        def no_strategy_error
          raise(
            Errors::DoubleDefinitionError,
            "This Double has no strategy"
          )
        end
      end
      include StrategySetupMethods

      class DoubleDefinitionCreateError < Errors::RRError
      end

      # Verification Strategies
      def mock(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
        self.add_verification_strategy(::RR::DoubleDefinitions::Strategies::Verification::Mock, subject, method_name, &definition_eval_block)
      end

      def mock!(method_name=nil, &definition_eval_block)
        mock(Object.new, method_name, &definition_eval_block)
      end

      def stub(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
        self.add_verification_strategy(::RR::DoubleDefinitions::Strategies::Verification::Stub, subject, method_name, &definition_eval_block)
      end

      def stub!(method_name=nil, &definition_eval_block)
        stub(Object.new, method_name, &definition_eval_block)
      end

      def dont_allow(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
        self.add_verification_strategy(::RR::DoubleDefinitions::Strategies::Verification::DontAllow, subject, method_name, &definition_eval_block)
      end

      def dont_allow!(method_name=nil, &definition_eval_block)
        dont_allow(Object.new, method_name, &definition_eval_block)
      end

      # Implementation Strategies
      def proxy(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
        self.add_implementation_strategy(::RR::DoubleDefinitions::Strategies::Implementation::Proxy, subject, method_name, &definition_eval_block)
      end

      def proxy!(method_name=nil, &definition_eval_block)
        proxy(Object.new, method_name, &definition_eval_block)
      end

      def strong(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
        self.add_implementation_strategy(::RR::DoubleDefinitions::Strategies::Implementation::StronglyTypedReimplementation, subject, method_name, &definition_eval_block)
      end

      def strong!(method_name=nil, &definition_eval_block)
        strong(Object.new, method_name, &definition_eval_block)
      end

      # Scope Strategies
      def any_instance_of(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
        self.add_scope_strategy(::RR::DoubleDefinitions::Strategies::Scope::AnyInstanceOfClass, subject, method_name, &definition_eval_block)
      end

      def any_instance_of!(method_name=nil, &definition_eval_block)
        any_instance_of(Object.new, method_name, &definition_eval_block)
      end

      def instance_of(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
        self.add_scope_strategy(::RR::DoubleDefinitions::Strategies::Scope::InstanceOfClass, subject, method_name, &definition_eval_block)
      end

      def instance_of!(method_name=nil, &definition_eval_block)
        instance_of(Object.new, method_name, &definition_eval_block)
      end
    end
  end
end