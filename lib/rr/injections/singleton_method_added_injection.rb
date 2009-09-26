module RR
  module Injections
    class SingletonMethodAddedInjection < Injection
      def initialize(subject)
        @subject = subject
      end

      def bind
        unless subject.respond_to?(original_method_alias_name)
          unless subject.respond_to?(:singleton_method_added)
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
        if subject.respond_to?(original_method_alias_name)
          me = self
          subject_class.class_eval do
            alias_method :singleton_method_added, me.send(:original_method_alias_name)
            remove_method me.send(:original_method_alias_name)
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
