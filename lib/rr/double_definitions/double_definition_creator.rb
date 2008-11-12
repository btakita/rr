module RR
  module DoubleDefinitions
    class DoubleDefinitionCreator # :nodoc
      class << self
        def register_verification_strategy_class(strategy_class, method_name)
          class_eval((<<-CLASS), __FILE__, __LINE__ + 1)
          def #{method_name}(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
            add_strategy(subject, method_name, definition_eval_block) do
              self.verification_strategy = #{strategy_class.name}.new(self)
            end
          end
          CLASS

          class_eval((<<-CLASS), __FILE__, __LINE__ + 1)
          def #{method_name}!(method_name=nil, &definition_eval_block)
            #{method_name}(Object.new, method_name, &definition_eval_block)
          end
          CLASS
        end
        
        def register_implementation_strategy_class(strategy_class, method_name)
          class_eval((<<-CLASS), __FILE__, __LINE__ + 1)
          def #{method_name}(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
            add_strategy(subject, method_name, definition_eval_block) do
              self.implementation_strategy = #{strategy_class.name}.new(self)
            end
          end
          CLASS

          class_eval((<<-CLASS), __FILE__, __LINE__ + 1)
          def #{method_name}!(method_name=nil, &definition_eval_block)
            #{method_name}(Object.new, method_name, &definition_eval_block)
          end
          CLASS
        end

        def register_scope_strategy_class(strategy_class, method_name)
          class_eval((<<-CLASS), __FILE__, __LINE__ + 1)
          def #{method_name}(subject=NO_SUBJECT, method_name=nil, &definition_eval_block)
            add_strategy(subject, method_name, definition_eval_block) do
              self.scope_strategy = #{strategy_class.name}.new(self)
            end
          end
          CLASS

          class_eval((<<-CLASS), __FILE__, __LINE__ + 1)
          def #{method_name}!(method_name=nil, &definition_eval_block)
            #{method_name}(Object.new, method_name, &definition_eval_block)
          end
          CLASS
        end
      end

      attr_reader :subject, 
                  :method_name, 
                  :args, :handler, 
                  :definition, 
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
        def add_strategy(subject, method_name, definition_eval_block)
          if method_name && definition_eval_block
            raise ArgumentError, "Cannot pass in a method name and a block"
          end
          @subject = subject
          yield
          if no_subject?
            self
          elsif method_name
            create(method_name)
          else
            DoubleDefinitionCreatorProxy.new(self, &definition_eval_block)
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

      module StrategyExecutionMethods
        def create(method_name, *args, &handler)
          raise DoubleDefinitionCreatorError if no_subject?
          @method_name, @args, @handler = method_name, args, handler
          @definition = DoubleDefinition.new(self, subject)
          verification_strategy ? verification_strategy.call(definition, method_name, args, handler) : no_strategy_error
          implementation_strategy.call(definition, method_name, args, handler)
          scope_strategy.call(definition, method_name, args, handler)
          definition
        end
      end
      include StrategyExecutionMethods

      class DoubleDefinitionCreatorError < Errors::RRError
      end
    end
  end
end