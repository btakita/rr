module RR
  module MethodDispatches
    class MethodMissingDispatch < BaseMethodDispatch
      extend(Module.new do
        def original_method_missing_alias_name
          "__rr__original_method_missing"
        end
      end)

      attr_reader :subject, :subject_class, :method_name
      def initialize(subject, subject_class, method_name, args, block)
        @subject, @subject_class, @method_name, @args, @block = subject, subject_class, method_name, args, block
      end

      def call
        if Injections::DoubleInjection.exists?(subject_class, method_name)
          @double = find_double_to_attempt
          if double
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
        Injections::DoubleInjection.find_or_create(subject_class, method_name).dispatch_method_delegates_to_dispatch_original_method do
          call_original_method_missing
        end
      end

      protected
      def call_implementation
        if implementation_is_original_method?
          space.record_call(subject, method_name, args, block)
          double.method_call(args)
          call_original_method
        else
          if double_injection = Injections::DoubleInjection.find(subject_class, method_name)
            double_injection.bind_method
            # The DoubleInjection takes care of calling double.method_call
            subject.__send__(method_name, *args, &block)
          else
            nil
          end
        end
      end

      def double_injection
        Injections::DoubleInjection.find_or_create(subject_class, method_name)
      end
    end
  end
end
