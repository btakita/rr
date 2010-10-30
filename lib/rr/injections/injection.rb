module RR
  module Injections
    class Injection
      extend(Module.new do
        def instances
          @instances ||= HashWithObjectIdKey.new
        end
      end)

      include Space::Reader
      include ClassInstanceMethodDefined

      def subject_has_method_defined?(method_name_in_question)
        class_instance_method_defined(subject_class, method_name_in_question)
      end

      def subject_has_original_method?
        subject_has_method_defined?(original_method_alias_name)
      end

      def original_method
        subject_class.instance_method(original_method_alias_name)
      end

      protected
      def subject_respond_to_method?(subject, method_name)
        subject_has_method_defined?(method_name) ||
          class_instance_method_defined(subject_class, :respond_to?) &&
          subject.respond_to?(method_name)
      end
    end
  end
end