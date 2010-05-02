module RR
  module Injections
    class SingletonMethodAddedInjection < Injection
      class << self
        def find_or_create(subject)
          instances[subject] ||= begin
            new(class << subject; self; end).bind(subject)
          end
        end

        def exists?(subject)
          instances.include?(subject)
        end
      end

      attr_reader :subject_class
      def initialize(subject_class)
        @subject_class = subject_class
        @placeholder_method_defined = false
      end

      def bind(subject)
        unless ClassInstanceMethodDefined.call(subject_class, original_method_alias_name)
          unless ClassInstanceMethodDefined.call(subject_class, :singleton_method_added)
            @placeholder_method_defined = true
            subject_class.class_eval do
              def singleton_method_added(method_name)
                super
              end
            end
          end

          memoized_original_method_alias_name = original_method_alias_name
          subject_class.__send__(:alias_method, original_method_alias_name, :singleton_method_added)
          subject_class.__send__(:define_method, :singleton_method_added) do |method_name_arg|
            if Injections::DoubleInjection.exists?(subject, method_name_arg)
              Injections::DoubleInjection.find_or_create(subject, method_name_arg).send(:deferred_bind_method, subject)
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
