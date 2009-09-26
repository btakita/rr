module RR
  module Injections
    # RR::DoubleInjection is the binding of an subject and a method.
    # A double_injection has 0 to many Double objects. Each Double
    # has Argument Expectations and Times called Expectations.
    class DoubleInjection < Injection
      attr_reader :subject_class, :method_name, :doubles

      MethodArguments = Struct.new(:arguments, :block)

      def initialize(subject, method_name, subject_class)
        @subject = subject
        @subject_class = subject_class
        @method_name = method_name.to_sym
        @doubles = []
      end

      # RR::DoubleInjection#register_double adds the passed in Double
      # into this DoubleInjection's list of Double objects.
      def register_double(double)
        @doubles << double
      end

      # RR::DoubleInjection#bind injects a method that acts as a dispatcher
      # that dispatches to the matching Double when the method
      # is called.
      def bind
        if subject_respond_to_method?(method_name)
          if subject_has_method_defined?(method_name)
            bind_method_with_alias
          else
            space.method_missing_injection(subject)
            space.singleton_method_added_injection(subject)
          end
        else
          bind_method
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
          subject_class.__send__(:alias_method, method_name, original_method_alias_name)
          subject_class.__send__(:remove_method, original_method_alias_name)
        else
          if subject_has_method_defined?(method_name)
            subject_class.__send__(:remove_method, method_name)
          end
        end
      end

      def dispatch_method(args, block)
        dispatch = MethodDispatches::MethodDispatch.new(self, args, block)
        if @bypass_bound_method
          dispatch.call_original_method
        else
          dispatch.call
        end
      end

      def dispatch_method_missing(method_name, args, block)
        MethodDispatches::MethodMissingDispatch.new(subject, method_name, args, block).call
      end

      def subject_has_original_method_missing?
        subject_respond_to_method?(original_method_missing_alias_name)
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
      def deferred_bind_method
        unless subject_has_method_defined?(original_method_alias_name)
          bind_method_with_alias
        end
        @performed_deferred_bind = true
      end

      def bind_method_with_alias
        subject_class.__send__(:alias_method, original_method_alias_name, method_name)
        bind_method
      end

      def bind_method
        returns_method = <<-METHOD
        def #{@method_name}(*args, &block)
          arguments = MethodArguments.new(args, block)
          RR::Space.double_injection(self, :#{@method_name}).dispatch_method(arguments.arguments, arguments.block)
        end
        METHOD
        subject_class.class_eval(returns_method, __FILE__, __LINE__ - 5)
      end
    end
  end
end
