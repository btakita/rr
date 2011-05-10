module RR
  module Injections
    class SingletonMethodAddedInjection < Injection
      extend(Module.new do
        def find_or_create(subject_class)
          instances[subject_class] ||= begin
            new(subject_class).bind
          end
        end

        def find(subject)
          instances[subject]
        end

        def exists?(subject)
          instances.include?(subject)
        end
      end)
      include ClassInstanceMethodDefined

      attr_reader :subject_class
      def initialize(subject_class)
        @subject_class = subject_class
        @placeholder_method_defined = false
      end

      def bind
        unless class_instance_method_defined(subject_class, original_method_alias_name, false)
          unless class_instance_method_defined(subject_class, :singleton_method_added, false)
            @placeholder_method_defined = true
            subject_class.class_eval do
              #def singleton_method_added(method_name)
              #  super
              #end
            end
          end

          memoized_original_method_alias_name = original_method_alias_name
          subject_class.__send__(:alias_method, original_method_alias_name, :singleton_method_added)
          memoized_subject_class = subject_class
          memoized_original_method_alias_name = original_method_alias_name
          subject_class.__send__(:define_method, :singleton_method_added) do |method_name_arg|
            if Injections::DoubleInjection.exists?(memoized_subject_class, method_name_arg)
              Injections::DoubleInjection.find_or_create(memoized_subject_class, method_name_arg).send(:deferred_bind_method)
            end
            __send__(memoized_original_method_alias_name, method_name_arg)
          end
        end
        self
      end

      def reset
        if subject_has_method_defined?(original_method_alias_name)
          memoized_original_method_alias_name = original_method_alias_name
          placeholder_method_defined = @placeholder_method_defined
          subject_class.class_eval do
            remove_method :singleton_method_added
            unless placeholder_method_defined
              alias_method :singleton_method_added, memoized_original_method_alias_name
            end
            remove_method memoized_original_method_alias_name
          end
        end
      end

      protected
      def original_method_alias_name
        "__rr__original_singleton_method_added"
      end
    end
  end
end
