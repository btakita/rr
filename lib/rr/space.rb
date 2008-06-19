module RR
  # RR::Space is a Dependency Injection http://en.wikipedia.org/wiki/Dependency_injection
  # and global state object for the RR framework. The RR::Space.instance
  # is a singleton that holds the state.
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

    attr_reader :double_injections, :ordered_doubles
    attr_accessor :trim_backtrace
    def initialize
      @double_injections = HashWithObjectIdKey.new
      @ordered_doubles = []
      @trim_backtrace = false
    end

    # Creates a DoubleDefinitionCreator.
    def double_definition_creator
      DoubleDefinitionCreator.new(self)
    end

    # Reuses or creates, if none exists, a DoubleInjection for the passed
    # in object and method_name.
    # When a DoubleInjection is created, it binds the dispatcher to the
    # object.
    def double_injection(object, method_name)
      double_injection = @double_injections[object][method_name.to_sym]
      return double_injection if double_injection

      double_injection = DoubleInjection.new(object, method_name.to_sym)
      @double_injections[object][method_name.to_sym] = double_injection
      double_injection.bind
      double_injection
    end

    # Registers the ordered Double to be verified.
    def register_ordered_double(double)
      @ordered_doubles << double
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
    def verify_doubles
      @double_injections.each do |object, method_double_map|
        method_double_map.keys.each do |method_name|
          verify_double(object, method_name)
        end
      end
    end
    alias_method :verify, :verify_doubles

    # Resets the registered Doubles and ordered Doubles
    def reset
      reset_ordered_doubles
      reset_double_injections
    end

    # Verifies the DoubleInjection for the passed in object and method_name.
    def verify_double(object, method_name)
      @double_injections[object][method_name].verify
    ensure
      reset_double object, method_name
    end

    # Resets the DoubleInjection for the passed in object and method_name.
    def reset_double(object, method_name)
      double_injection = @double_injections[object].delete(method_name)
      @double_injections.delete(object) if @double_injections[object].empty?
      double_injection.reset
    end

    protected
    # Removes the ordered Doubles from the list
    def reset_ordered_doubles
      @ordered_doubles.clear
    end

    # Resets the registered Doubles for the next test run.
    def reset_double_injections
      @double_injections.each do |object, method_double_map|
        method_double_map.keys.each do |method_name|
          reset_double(object, method_name)
        end
      end
    end    
  end
end