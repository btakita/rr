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
      def bind
        if subject_respond_to_method?(method_name)
          if subject_has_method_defined?(method_name)
            bind_method_with_alias
          else
            me = self

            space.method_missing_injection(subject)

            unless subject.respond_to?(original_singleton_method_added_alias_name)
              unless subject.respond_to?(:singleton_method_added)
                subject_class.class_eval do
                  def singleton_method_added(method_name)
                    super
                  end
                end
              end

              subject_class.__send__(:alias_method, original_singleton_method_added_alias_name, :singleton_method_added)
              subject_class.__send__(:define_method, :singleton_method_added) do |method_name_arg|
                if me.space.double_injection_exists?(me.subject, method_name_arg)
                  me.space.double_injection(me.subject, method_name_arg).send(:deferred_bind_method)
                end
                send(me.send(:original_singleton_method_added_alias_name), method_name_arg)
              end
            end
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
        reset_bound_method
        reset_singleton_method_added
      end

      def reset_bound_method
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

      def reset_singleton_method_added
        if subject.respond_to?(original_singleton_method_added_alias_name)
          me = self
          subject_class.class_eval do
            alias_method :singleton_method_added, me.send(:original_singleton_method_added_alias_name)
            remove_method me.send(:original_singleton_method_added_alias_name)
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

      def bind_method_missing
        returns_method = <<-METHOD
        def method_missing(method_name, *args, &block)
          RR::Space.double_injection(self, :#{@method_name}).dispatch_method_missing(method_name, args, block)
        end
        METHOD
        subject_class.class_eval(returns_method, __FILE__, __LINE__ - 4)
      end

      def original_singleton_method_added_alias_name
        "__rr__original_singleton_method_added"
      end
    end
  end
end
