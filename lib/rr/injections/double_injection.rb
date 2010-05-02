module RR
  module Injections
    # RR::DoubleInjection is the binding of an subject and a method.
    # A double_injection has 0 to many Double objects. Each Double
    # has Argument Expectations and Times called Expectations.
    class DoubleInjection < Injection
      class << self
        # TODO: Pass in subject_class
        def create(subject, method_name)
          instances[subject][method_name.to_sym] ||= begin
            new(class << subject; self; end, method_name.to_sym).bind(subject)
          end
        end

        def dispatch_method(subject, method_name, arguments, block)
          if exists?(subject, method_name)
            instances[subject][method_name.to_sym].dispatch_method(subject, arguments, block)
          else
            injection = new(class << subject; self; end, method_name.to_sym)
            injection.bypass_bound_method do
              injection.dispatch_method(subject, arguments, block)
            end
          end
        end

        def exists?(subject, method_name)
          instances.include?(subject) && instances[subject].include?(method_name.to_sym)
        end

        def reset
          instances.each do |subject, method_double_map|
            method_double_map.keys.each do |method_name|
              reset_double(subject, method_name)
            end
          end
        end

        def verify(*subjects)
          subjects = Injections::DoubleInjection.instances.keys if subjects.empty?
          subjects.each do |subject|
            instances.include?(subject) &&
              instances[subject].keys.each do |method_name|
                verify_double(subject, method_name)
              end &&
              instances.delete(subject)
          end
        end

        # Verifies the DoubleInjection for the passed in subject and method_name.
        def verify_double(subject, method_name)
          Injections::DoubleInjection.instances[subject][method_name].verify
        ensure
          reset_double subject, method_name
        end

        # Resets the DoubleInjection for the passed in subject and method_name.
        def reset_double(subject, method_name)
          double_injection = Injections::DoubleInjection.instances[subject].delete(method_name)
          Injections::DoubleInjection.instances.delete(subject) if Injections::DoubleInjection.instances[subject].empty?
          double_injection.reset
        end

        def instances
          @instances ||= HashWithObjectIdKey.new do |hash, subject_object|
            hash.set_with_object_id(subject_object, {})
          end
        end
      end

      attr_reader :subject_class, :method_name, :doubles

      MethodArguments = Struct.new(:arguments, :block)

      def initialize(subject_class, method_name)
        @subject_class = subject_class
        @method_name = method_name.to_sym
        @doubles = []
        @bypass_bound_method = nil
      end

      # RR::DoubleInjection#register_double adds the passed in Double
      # into this DoubleInjection's list of Double objects.
      def register_double(double)
        @doubles << double
      end

      # RR::DoubleInjection#bind injects a method that acts as a dispatcher
      # that dispatches to the matching Double when the method
      # is called.
      def bind(subject)
        # subject needed
        if subject_respond_to_method?(subject, method_name)
          if subject_has_method_defined?(method_name)
            if subject_is_proxy_for_method?(method_name)
              bind_method(subject)
            else
              bind_method_with_alias(subject)
            end
          else
            Injections::MethodMissingInjection.create(subject)
            Injections::SingletonMethodAddedInjection.create(subject)
          end
        else
          bind_method(subject)
        end
        self
      end

      # RR::DoubleInjection#verify verifies each Double
      # TimesCalledExpectation are met.
      def verify
        @doubles.each do |double|
          double.verify
        end
      end

      # RR::DoubleInjection#reset removes the injected dispatcher method.

      # It binds the original method implementation on the subject
      # if one exists.
      def reset
        if subject_has_original_method?
          subject_class.__send__(:remove_method, method_name)
          subject_class.__send__(:alias_method, method_name, original_method_alias_name)
          subject_class.__send__(:remove_method, original_method_alias_name)
        else
          if subject_has_method_defined?(method_name)
            subject_class.__send__(:remove_method, method_name)
          end
        end
      end

      def dispatch_method(subject, args, block)
        dispatch = MethodDispatches::MethodDispatch.new(self, subject, args, block)
        if @bypass_bound_method
          dispatch.call_original_method
        else
          dispatch.call
        end
      end

      def subject_has_original_method_missing?
        ClassInstanceMethodDefined.call(subject_class, original_method_missing_alias_name)
      end

      def original_method_alias_name
        "__rr__original_#{@method_name}"
      end

      def original_method_missing_alias_name
        MethodDispatches::MethodMissingDispatch.original_method_missing_alias_name
      end

      def bypass_bound_method
        @bypass_bound_method = true
        yield
      ensure
        @bypass_bound_method = nil
      end

      protected
      def subject_is_proxy_for_method?(method_name_in_question)
        !subject_class.
          instance_methods.
          detect {|method_name| method_name.to_sym == method_name_in_question.to_sym}
      end

      def deferred_bind_method(subject)
        unless subject_has_method_defined?(original_method_alias_name)
          bind_method_with_alias(subject)
        end
        @performed_deferred_bind = true
      end

      def bind_method_with_alias(subject)
        subject_class.__send__(:alias_method, original_method_alias_name, method_name)
        bind_method(subject)
      end

      def bind_method(subject)
        subject_class.class_eval(<<-METHOD, __FILE__, __LINE__ + 1)
        def #{@method_name}(*args, &block)
          arguments = MethodArguments.new(args, block)

          RR::Injections::DoubleInjection.dispatch_method(self, :#{method_name}, arguments.arguments, arguments.block)
        end
        METHOD
      end
    end
  end
end
