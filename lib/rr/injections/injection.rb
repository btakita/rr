module RR
  module Injections
    class Injection
      class << self
        def instances
          @instances ||= HashWithObjectIdKey.new
        end
      end

      include Space::Reader

      attr_reader :subject

      def subject_has_method_defined?(method_name_in_question)
        @subject.methods.detect {|method_name| method_name.to_sym == method_name_in_question.to_sym} ||
          @subject.protected_methods.detect {|method_name| method_name.to_sym == method_name_in_question.to_sym} ||
          @subject.private_methods.detect {|method_name| method_name.to_sym == method_name_in_question.to_sym}
      end

      def subject_has_original_method?
        subject_respond_to_method?(original_method_alias_name)
      end

      protected
      def subject_respond_to_method?(method_name)
        subject_has_method_defined?(method_name) || @subject.respond_to?(method_name)
      end
    end
  end
end