module RR
  module DoubleDefinitions
    class DoubleDefinitionBuilder #:nodoc:
      attr_reader :definition

      def initialize(definition, args, handler)
        @definition = definition
        @args = args
        @handler = handler
      end

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
    end    
  end
end
