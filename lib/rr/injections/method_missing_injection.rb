module RR
  module Injections
    class MethodMissingInjection < Injection
      def initialize(subject)
        @subject = subject
      end

      def bind
        unless subject.respond_to?(original_method_alias_name)
          unless subject.respond_to?(:method_missing)
            @placeholder_method_defined = true
            subject_class.class_eval do
              def method_missing(method_name, *args, &block)
                super
              end
            end
          end
          subject_class.__send__(:alias_method, original_method_alias_name, :method_missing)
          bind_method
        end
        self
      end

      def reset
        if subject_has_method_defined?(original_method_alias_name)
          memoized_original_method_alias_name = original_method_alias_name
          placeholder_method_defined = @placeholder_method_defined
          subject_class.class_eval do
            if placeholder_method_defined
              remove_method :method_missing
            else
              alias_method :method_missing, memoized_original_method_alias_name
            end
            remove_method memoized_original_method_alias_name
          end
        end
      end

      def dispatch_method(method_name, args, block)
        MethodDispatches::MethodMissingDispatch.new(subject, method_name, args, block).call
      end

      protected
      def subject_class
        class << subject; self; end
      end

      def bind_method
        returns_method = <<-METHOD
        def method_missing(method_name, *args, &block)
          RR::Space.method_missing_injection(self).dispatch_method(method_name, args, block)
        end
        METHOD
        subject_class.class_eval(returns_method, __FILE__, __LINE__ - 4)
      end

      def original_method_alias_name
        MethodDispatches::MethodMissingDispatch.original_method_missing_alias_name
      end
    end
  end
end
