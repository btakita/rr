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
      def implementation
        definition.implementation
      end

      def subject_has_original_method?
        double_injection.subject_has_original_method?
      end

      def subject_has_original_method_missing?
        double_injection.subject_has_original_method_missing?
      end

      def subject
        double_injection.subject
      end

      def method_name
        double_injection.method_name
      end

      def original_method_alias_name
        double_injection.original_method_alias_name
      end
    end
  end
end
