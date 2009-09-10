module RR
  module MethodDispatches
    class MethodMissingDispatch < BaseMethodDispatch
      attr_reader :method_name
      def initialize(double_injection, method_name, args, block)
        @double_injection, @args, @block = double_injection, args, block
        @method_name = method_name
      end

      def call
        if double_injection.method_name == method_name
          space.record_call(subject, method_name, args, block)
          @double = find_double_to_attempt

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
        else
          call_original_method
        end
      end

      def call_original_method
        double_injection.bypass_bound_method do
          call_original_method_missing
        end
      end

      protected

      def original_method_missing_alias_name
        double_injection.original_method_missing_alias_name
      end

      def subject
        double_injection.subject
      end
    end
  end
end
