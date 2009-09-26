module RR
  module Injections
    class SingletonMethodAddedInjection < Injection
      def initialize(subject)
        @subject = subject
      end

      def bind
        unless subject.respond_to?(original_method_alias_name)
          unless subject.respond_to?(:singleton_method_added)
            @placeholder_method_defined = true
            subject_class.class_eval do
              def singleton_method_added(method_name)
                super
              end
            end
          end

          memoized_subject = subject
          memoized_space = space
          memoized_original_method_alias_name = original_method_alias_name
          subject_class.__send__(:alias_method, original_method_alias_name, :singleton_method_added)
          subject_class.__send__(:define_method, :singleton_method_added) do |method_name_arg|
            if memoized_space.double_injection_exists?(memoized_subject, method_name_arg)
              memoized_space.double_injection(memoized_subject, method_name_arg).send(:deferred_bind_method)
            end
            send(memoized_original_method_alias_name, method_name_arg)
          end
        end
        self
      end

      def reset
        if subject_has_method_defined?(original_method_alias_name)
          memoized_original_method_alias_name = original_method_alias_name
          placeholder_method_defined = @placeholder_method_defined
          subject_class.class_eval do
            if placeholder_method_defined
              remove_method :singleton_method_added
            else
              alias_method :singleton_method_added, memoized_original_method_alias_name
            end
            remove_method memoized_original_method_alias_name
          end
        end
      end

      protected
      def subject_class
        class << subject; self; end
      end

      def original_method_alias_name
        "__rr__original_singleton_method_added"
      end
    end
  end
end
