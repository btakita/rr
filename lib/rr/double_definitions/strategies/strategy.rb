module RR
  module DoubleDefinitions
    module Strategies
      class Strategy
        attr_reader :double_definition_create, :definition, :method_name, :args, :handler
        include Space::Reader

        def initialize(double_definition_create)
          @double_definition_create = double_definition_create
        end
        
        def call(definition, method_name, args, handler)
          @definition, @method_name, @args, @handler = definition, method_name, args, handler
          do_call
        end

        def verify_subject(subject)
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
      end
    end
  end
end