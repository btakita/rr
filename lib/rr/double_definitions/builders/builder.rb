module RR
  module DoubleDefinitions
    module Builders
      class Builder #:nodoc:
        attr_reader :definition, :args, :handler, :core_strategy
        include Errors

        def initialize
          @is_using_proxy_strategy = false
          @core_strategy = nil
        end

        def build(definition, args, handler)
          @definition, @args, @handler = definition, args, handler
          verify_strategy
          send(@core_strategy)
          is_using_proxy_strategy?? proxy : reimplementation
          @definition
        end

        def set_core_strategy(strategy)
          verify_no_core_strategy
          @core_strategy = strategy
          proxy_when_dont_allow_error if strategy == :dont_allow && @is_using_proxy_strategy
        end

        def using_proxy_strategy
          proxy_when_dont_allow_error if @core_strategy == :dont_allow
          @is_using_proxy_strategy = true
        end

        def is_using_proxy_strategy?
          !!@is_using_proxy_strategy
        end

        protected
        def mock
          @definition.with(*@args).once
        end

        def stub
          @definition.any_number_of_times
          permissive_argument
        end

        def dont_allow
          @definition.never
          permissive_argument
          reimplementation
        end

        def permissive_argument
          if @args.empty?
            @definition.with_any_args
          else
            @definition.with(*@args)
          end
        end

        def reimplementation
          @definition.returns(&@handler)
        end

        def proxy
          @definition.after_call_block_callback_strategy
          @definition.proxy
          @definition.after_call(&@handler) if @handler
        end

        def verify_no_core_strategy
          strategy_already_defined_error if @core_strategy
        end

        def strategy_already_defined_error
          raise(
            DoubleDefinitionError,
            "This Double already has a #{@core_strategy} strategy"
          )
        end

        def proxy_when_dont_allow_error
          raise(
            DoubleDefinitionError,
            "Doubles cannot be proxied when using dont_allow strategy"
          )
        end

        def verify_strategy
          no_strategy_error unless @core_strategy
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
end
