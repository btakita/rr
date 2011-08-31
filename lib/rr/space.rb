module RR
  # RR::Space.instance is the global state subject for the RR framework.
  class Space
    module Reader
      def space
        RR::Space.instance
      end
    end

    class << self
      def instance
        @instance ||= new
      end
      attr_writer :instance

      protected
      def method_missing(method_name, *args, &block)
        instance.__send__(method_name, *args, &block)
      end
    end

    attr_reader :ordered_doubles, :recorded_calls
    attr_accessor :trim_backtrace
    def initialize
      @ordered_doubles = []
      @trim_backtrace = false
      @recorded_calls = RR::RecordedCalls.new
    end

    # Registers the ordered Double to be verified.
    def register_ordered_double(double)
      @ordered_doubles << double unless ordered_doubles.include?(double)
    end

    # Verifies that the passed in ordered Double is being called
    # in the correct position.
    def verify_ordered_double(double)
      unless double.terminal?
        raise Errors::DoubleOrderError,
              "Ordered Doubles cannot have a NonTerminal TimesCalledExpectation"
      end
      unless @ordered_doubles.first == double
        message = Double.formatted_name(double.method_name, double.expected_arguments)
        message << " called out of order in list\n"
        message << Double.list_message_part(@ordered_doubles)
        raise Errors::DoubleOrderError, message
      end
      @ordered_doubles.shift unless double.attempt?
      double
    end

    # Verifies all the DoubleInjection objects have met their
    # TimesCalledExpectations.
    def verify_doubles(*subjects)
      Injections::DoubleInjection.verify(*subjects)
    end
    alias_method :verify, :verify_doubles

    # Resets the registered Doubles and ordered Doubles
    def reset
      reset_ordered_doubles
      Injections::DoubleInjection.reset
      reset_method_missing_injections
      reset_singleton_method_added_injections
      reset_recorded_calls
      reset_bound_objects
    end

    # Verifies the DoubleInjection for the passed in subject and method_name.
    def verify_double(subject, method_name)
      Injections::DoubleInjection.verify_double(class << subject; self; end, method_name)
    end

    # Resets the DoubleInjection for the passed in subject and method_name.
    def reset_double(subject, method_name)
      Injections::DoubleInjection.reset_double(class << subject; self; end, method_name)
    end

    def record_call(subject, method_name, arguments, block)
      @recorded_calls << [subject, method_name, arguments, block]
    end

    def blank_slate_whitelist
      @blank_slate_whitelist ||= [
        "object_id", "respond_to?", "respond_to_missing?", "method_missing", "instance_eval", "instance_exec", "class_eval"
      ]
    end

    protected
    # Removes the ordered Doubles from the list
    def reset_ordered_doubles
      @ordered_doubles.clear
    end

    def reset_method_missing_injections
      Injections::MethodMissingInjection.instances.each do |subject_class, injection|
        injection.reset
      end
      Injections::MethodMissingInjection.instances.clear
    end

    def reset_singleton_method_added_injections
      Injections::SingletonMethodAddedInjection.instances.each do |subject, injection|
        injection.reset
      end
      Injections::SingletonMethodAddedInjection.instances.clear
    end

    def reset_recorded_calls
      @recorded_calls.clear
    end

    def reset_bound_objects
      # TODO: Figure out how to clear and reset these bindings
      #RR::Injections::DoubleInjection::BoundObjects.clear
      #RR::Injections::DoubleInjection::MethodMissingInjection.clear
    end
  end
end
