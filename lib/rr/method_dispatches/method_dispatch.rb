module RR
  module MethodDispatches
    class MethodDispatch < BaseMethodDispatch
      attr_reader :double_injection
      def initialize(double_injection, args, block)
        @double_injection, @args, @block = double_injection, args, block
        @double = find_double_to_attempt
      end

      def call
        space.record_call(subject, method_name, args, block)
        if double
          double.method_call(args)
          call_yields
          return_value = extract_subject_from_return_value(call_implementation)
          if after_call_proc
            extract_subject_from_return_value(after_call_proc.call(return_value))
          else
            return_value
          end
        else
          double_not_found_error
        end
      end

      def call_original_method
        if subject_has_original_method?
          subject.__send__(original_method_alias_name, *args, &block)
        elsif subject_has_original_method_missing?
          call_original_method_missing
        else
          subject.__send__(:method_missing, method_name, *args, &block)
        end
      end

      protected
      def call_implementation
        if implementation_is_original_method?
          call_original_method
        else
          if implementation
            if implementation.is_a?(Method)
              implementation.call(*args, &block)
            else
              call_args = block ? args + [ProcFromBlock.new(&block)] : args
              implementation.call(*call_args)
            end
          else
            nil
          end
        end
      end

      def_delegators :definition, :implementation
      def_delegators :double_injection, :subject_has_original_method?, :subject_has_original_method_missing?, :subject, :method_name, :original_method_alias_name
    end
  end
end
