module RR
  # RR::DoubleInjection is the binding of an subject and a method.
  # A double_injection has 0 to many Double objects. Each Double
  # has Argument Expectations and Times called Expectations.
  class DoubleInjection
    include Space::Reader

    MethodArguments = Struct.new(:arguments, :block)
    attr_reader :subject, :method_name, :doubles, :subject_class

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
          me = self
          previously_bound = false
          subject_class.__send__(:alias_method, original_singleton_method_added_alias_name, :singleton_method_added)

          subject_class.__send__(:define_method, :singleton_method_added) do |method_name_arg|
            if method_name_arg.to_sym == me.method_name.to_sym && !previously_bound
              previously_bound = true
              me.send(:deferred_bind_method)
              send(me.send(:original_singleton_method_added_alias_name), method_name_arg)
            else
              send(me.send(:original_singleton_method_added_alias_name), method_name_arg)
            end
          end
          @deferred_bind = true
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
        subject_class.__send__(:alias_method, @method_name, original_method_alias_name)
        subject_class.__send__(:remove_method, original_method_alias_name)
      else
        if @deferred_bind
          me = self
          subject_class.class_eval do
            alias_method :singleton_method_added, me.send(:original_singleton_method_added_alias_name)
            remove_method me.send(:original_singleton_method_added_alias_name)
          end

          if @performed_deferred_bind
            subject_class.__send__(:remove_method, @method_name)
          end
        else
          subject_class.__send__(:remove_method, @method_name)
        end
      end
    end

    def subject_has_original_method?
      subject_respond_to_method?(original_method_alias_name)
    end

    def call_method(args, block)
      DoubleInjectionDispatch.new(self, args, block).call
    end

    def call_original_method(args, block)
      subject.__send__(original_method_alias_name, *args, &block)
    end

    def call_method_missing(args, block)
      if @deferred_bind
        return_value = subject.__send__(:method_missing, method_name, *args, &block)
        deferred_bind_method
        return_value
      else
        subject.__send__(:method_missing, method_name, *args, &block)
      end
    end

    protected
    def deferred_bind_method
      bind_method_with_alias
      @deferred_bind = nil
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
          RR::Space.double_injection(self, :#{@method_name}).call_method(arguments.arguments, arguments.block)
        end
      METHOD
      subject_class.class_eval(returns_method, __FILE__, __LINE__ - 5)
    end

    def original_method_alias_name
      "__rr__original_#{@method_name}"
    end

    def original_singleton_method_added_alias_name
      "__rr__original_singleton_method_added"
    end

    def subject_respond_to_method?(method_name)
      subject_has_method_defined?(method_name) || @subject.respond_to?(method_name)
    end

    def subject_has_method_defined?(method_name)
      @subject.methods.include?(method_name.to_s) || @subject.protected_methods.include?(method_name.to_s) || @subject.private_methods.include?(method_name.to_s)
    end
  end
end
