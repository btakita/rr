module RR
  module MethodDispatches
    class MethodMissingDispatch < BaseMethodDispatch
      class << self
        def original_method_missing_alias_name
          "__rr__original_method_missing"
        end
      end

      attr_reader :subject, :method_name
      def initialize(subject, method_name, args, block)
        @subject, @method_name, @args, @block = subject, method_name, args, block
      end

      def call
        if space.double_injection_exists?(subject, method_name)
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
      def call_implementation
        if implementation_is_original_method?
          call_original_method
        else
          nil
        end
      end

      def double_injection
        space.double_injection(subject, method_name)
      end

      def_delegators 'self.class', :original_method_missing_alias_name
    end
  end
end
