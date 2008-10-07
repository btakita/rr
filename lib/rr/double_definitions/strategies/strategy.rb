module RR
  module DoubleDefinitions
    module Strategies
      class Strategy
        attr_reader :double_definition_creator, :definition, :method_name, :args, :handler
        include Space::Reader

        def initialize(double_definition_creator)
          @double_definition_creator = double_definition_creator
        end
        
        def call(definition, method_name, args, handler)
          @definition, @method_name, @args, @handler = definition, method_name, args, handler
          do_call
        end

        def name
          self.class.domain_name
        end

        protected
        def do_call
          raise NotImplementedError
        end

        def permissive_argument
          if args.empty?
            definition.with_any_args
          else
            definition.with(*args)
          end
        end

        def reimplementation
          definition.returns(&handler)
        end

        def subject
          definition.subject
        end

        def double_definition_creator
          definition.double_definition_creator
        end
      end
    end
  end
end