module RR
  module Injections
    # RR::DoubleInjection is the binding of an subject and a method.
    # A double_injection has 0 to many Double objects. Each Double
    # has Argument Expectations and Times called Expectations.
    class DoubleInjection < Injection
      extend(Module.new do
        def find_or_create(subject_class, method_name)
          instances[subject_class][method_name.to_sym] ||= begin
            new(subject_class, method_name.to_sym).bind
          end
        end

        def find_or_create_by_subject(subject, method_name)
          find_or_create(class << subject; self; end, method_name)
        end

        def find(subject_class, method_name)
          instances[subject_class] && instances[subject_class][method_name.to_sym]
        end

        def find_by_subject(subject, method_name)
          find(class << subject; self; end, method_name)
        end

        def exists?(subject_class, method_name)
          !!find(subject_class, method_name)
        end

        def exists_by_subject?(subject, method_name)
          exists?((class << subject; self; end), method_name)
        end

        def dispatch_method(subject, subject_class, method_name, arguments, block)
          subject_eigenclass = (class << subject; self; end)
          if (
            exists?(subject_class, method_name) &&
            (subject_class == subject_eigenclass) || !subject.is_a?(Class)
          )
            find(subject_class, method_name.to_sym).dispatch_method(subject, arguments, block)
          else
            new(subject_class, method_name.to_sym).dispatch_original_method(subject, arguments, block)
          end
        end

        def reset
          instances.each do |subject_class, method_double_map|
            SingletonMethodAddedInjection.find(subject_class) && SingletonMethodAddedInjection.find(subject_class).reset
            method_double_map.keys.each do |method_name|
              reset_double(subject_class, method_name)
            end
            Injections::DoubleInjection.instances.delete(subject_class) if Injections::DoubleInjection.instances.has_key?(subject_class)
          end
        end

        def verify(*subjects)
          subject_classes = subjects.empty? ?
            Injections::DoubleInjection.instances.keys :
            subjects.map {|subject| class << subject; self; end}
          subject_classes.each do |subject_class|
            instances.include?(subject_class) &&
              instances[subject_class].keys.each do |method_name|
                verify_double(subject_class, method_name)
              end &&
              instances.delete(subject_class)
          end
        end

        # Verifies the DoubleInjection for the passed in subject and method_name.
        def verify_double(subject_class, method_name)
          Injections::DoubleInjection.find(subject_class, method_name).verify
        ensure
          reset_double subject_class, method_name
        end

        # Resets the DoubleInjection for the passed in subject and method_name.
        def reset_double(subject_class, method_name)
          double_injection = Injections::DoubleInjection.instances[subject_class].delete(method_name)
          double_injection.reset
          Injections::DoubleInjection.instances.delete(subject_class) if Injections::DoubleInjection.instances[subject_class].empty?
        end

        def instances
          @instances ||= HashWithObjectIdKey.new do |hash, subject_class|
            hash.set_with_object_id(subject_class, {})
          end
        end
      end)
      include ClassInstanceMethodDefined

      attr_reader :subject_class, :method_name, :doubles

      MethodArguments = Struct.new(:arguments, :block)

      def initialize(subject_class, method_name)
        @subject_class = subject_class
        @method_name = method_name.to_sym
        @doubles = []
        @dispatch_method_delegates_to_dispatch_original_method = nil
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
        if subject_has_method_defined?(method_name)
          bind_method_with_alias
        else
          Injections::MethodMissingInjection.find_or_create(subject_class)
          Injections::SingletonMethodAddedInjection.find_or_create(subject_class)
          bind_method_that_self_destructs_and_delegates_to_method_missing
        end
        self
      end

      BoundObjects = {}

      def bind_method_that_self_destructs_and_delegates_to_method_missing
        id = BoundObjects.size
        BoundObjects[id] = subject_class

        subject_class.class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def #{method_name}(*args, &block)
          ::RR::Injections::DoubleInjection::BoundObjects[#{id}].class_eval do
            remove_method(:#{method_name})
          end
          method_missing(:#{method_name}, *args, &block)
        end
        RUBY
        self
      end

      def bind_method
        id = BoundObjects.size
        BoundObjects[id] = subject_class

        subject_class.class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def #{method_name}(*args, &block)
          arguments = MethodArguments.new(args, block)
          obj = ::RR::Injections::DoubleInjection::BoundObjects[#{id}]
          RR::Injections::DoubleInjection.dispatch_method(self, obj, :#{method_name}, arguments.arguments, arguments.block)
        end
        RUBY
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
        if @dispatch_method_delegates_to_dispatch_original_method
          dispatch_original_method(subject, args, block)
        else
          dispatch = MethodDispatches::MethodDispatch.new(self, subject, args, block)
          dispatch.call
        end
      end

      def dispatch_original_method(subject, args, block)
        dispatch = MethodDispatches::MethodDispatch.new(self, subject, args, block)
        dispatch.call_original_method
      end

      def subject_has_original_method_missing?
        class_instance_method_defined(subject_class, MethodDispatches::MethodMissingDispatch.original_method_missing_alias_name)
      end

      def original_method_alias_name
        "__rr__original_#{@method_name}"
      end

      def dispatch_method_delegates_to_dispatch_original_method
        @dispatch_method_delegates_to_dispatch_original_method = true
        yield
      ensure
        @dispatch_method_delegates_to_dispatch_original_method = nil
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
    end
  end
end
