module RR
  module DoubleDefinitions
    module Strategies
      class Strategy
        attr_reader :definition, :args, :handler
        def call(definition, args, handler)
          @definition, @args, @handler = definition, args, handler
          do_call
        end

        def name
          raise NotImplementedError
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
          definition.returns(&@handler)
        end
      end
    end
  end
end