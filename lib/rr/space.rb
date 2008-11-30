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

    attr_reader :double_injections, :ordered_doubles, :recorded_calls
    attr_accessor :trim_backtrace
    def initialize
      @double_injections = HashWithObjectIdKey.new
      @ordered_doubles = []
      @trim_backtrace = false
      @recorded_calls = RR::RecordedCalls.new
    end

    # Reuses or creates, if none exists, a DoubleInjection for the passed
    # in subject and method_name.
    # When a DoubleInjection is created, it binds the dispatcher to the
    # subject.
    def double_injection(subject, method_name)
      @double_injections[subject][method_name.to_sym] ||= begin
        DoubleInjection.new(subject, method_name.to_sym).bind
      end
    end

    def double_injection_exists?(subject, method_name)
      !!@double_injections[subject][method_name.to_sym]
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
    def verify_doubles(*objects)
      objects = @double_injections.keys if objects.empty?
      objects.each do |subject|
        @double_injections[subject].keys.each do |method_name|
          verify_double(subject, method_name)
        end
      end
    end
    alias_method :verify, :verify_doubles

    # Resets the registered Doubles and ordered Doubles
    def reset
      reset_ordered_doubles
      reset_double_injections
      reset_recorded_calls
    end

    # Verifies the DoubleInjection for the passed in subject and method_name.
    def verify_double(subject, method_name)
      @double_injections[subject][method_name].verify
    ensure
      reset_double subject, method_name
    end

    # Resets the DoubleInjection for the passed in subject and method_name.
    def reset_double(subject, method_name)
      double_injection = @double_injections[subject].delete(method_name)
      @double_injections.delete(subject) if @double_injections[subject].empty?
      double_injection.reset
    end
    
    def record_call(subject, method_name, arguments, block)
      @recorded_calls << [subject, method_name, arguments, block]
    end

    protected
    # Removes the ordered Doubles from the list
    def reset_ordered_doubles
      @ordered_doubles.clear
    end

    # Resets the registered Doubles for the next test run.
    def reset_double_injections
      @double_injections.each do |subject, method_double_map|
        method_double_map.keys.each do |method_name|
          reset_double(subject, method_name)
        end
      end
    end  
    
    def reset_recorded_calls
      @recorded_calls.clear
    end
  end
end