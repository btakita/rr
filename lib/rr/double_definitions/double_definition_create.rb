module RR
  module DoubleDefinitions
    class DoubleDefinitionCreate # :nodoc
      extend(Module.new do
        def default_double_injection_strategy_class
          @default_double_injection_strategy_class ||= Strategies::DoubleInjection::Instance
        end

        def set_default_double_injection_strategy_class(strategy_class)
          original_strategy_class = default_double_injection_strategy_class
          begin
            @default_double_injection_strategy_class = strategy_class
            yield
          ensure
            @default_double_injection_strategy_class = original_strategy_class
          end
        end
      end)

      attr_reader :subject, :verification_strategy, :implementation_strategy, :double_injection_strategy
      NO_SUBJECT = Object.new

      include Space::Reader

      def initialize
        @verification_strategy = nil
        @implementation_strategy = Strategies::Implementation::Reimplementation.new(self)
        @double_injection_strategy = self.class.default_double_injection_strategy_class.new(self)
      end

      def call(method_name, *args, &handler)
        definition = DoubleDefinition.new(self)
        verification_strategy || no_strategy_error
        if subject.is_a?(PrototypeSubject)
          subject.method_name = method_name
          subject.double_definition = definition
          subject.verification_strategy = verification_strategy
          subject.implementation_strategy = implementation_strategy
          # double_injection_strategy is deprecated and will not be used for PrototypeSubjects.
          # PrototypeSubjects are used in the AnyInstanceOf double_injection.
        else
          verification_strategy.call(definition, method_name, args, handler)
          implementation_strategy.call(definition, method_name, args, handler)
          double_injection_strategy.call(definition, method_name, args, handler)
        end
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

        def add_double_injection_strategy(double_injection_strategy_class, subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
          add_strategy(subject, method_name, definition_eval_block) do
            self.double_injection_strategy = double_injection_strategy_class.new(self)
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
          @verification_strategy = verification_strategy
          verification_strategy
        end

        def implementation_strategy=(implementation_strategy)
          @implementation_strategy = implementation_strategy
        end

        def double_injection_strategy=(double_injection_strategy)
          @double_injection_strategy = double_injection_strategy
        end
      end
      include StrategySetupMethods

      class DoubleDefinitionCreateError < Errors::RRError
      end

      # Verification Strategies
      include ::RR::DoubleDefinitions::Strategies::StrategyMethods
      def mock(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
        self.add_verification_strategy(::RR::DoubleDefinitions::Strategies::Verification::Mock, subject, method_name, &definition_eval_block)
      end

      def stub(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
        self.add_verification_strategy(::RR::DoubleDefinitions::Strategies::Verification::Stub, subject, method_name, &definition_eval_block)
      end

      def dont_allow(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
        self.add_verification_strategy(::RR::DoubleDefinitions::Strategies::Verification::DontAllow, subject, method_name, &definition_eval_block)
      end

      # Implementation Strategies
      def proxy(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
        self.add_implementation_strategy(::RR::DoubleDefinitions::Strategies::Implementation::Proxy, subject, method_name, &definition_eval_block)
      end

      def strong(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
        self.add_implementation_strategy(::RR::DoubleDefinitions::Strategies::Implementation::StronglyTypedReimplementation, subject, method_name, &definition_eval_block)
      end

      # DoubleInjection Strategies
      def any_instance_of(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
        self.add_double_injection_strategy(::RR::DoubleDefinitions::Strategies::DoubleInjection::AnyInstanceOfClass, subject, method_name, &definition_eval_block)
      end

      def instance_of(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
        self.add_double_injection_strategy(::RR::DoubleDefinitions::Strategies::DoubleInjection::NewInstanceOf, subject, method_name, &definition_eval_block)
      end
    end
  end
end