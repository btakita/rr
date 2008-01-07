module RR
  # RR::Space is a Dependency Injection http://en.wikipedia.org/wiki/Dependency_injection
  # and global state object for the RR framework. The RR::Space.instance
  # is a singleton that holds the state.
  class Space
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

    attr_reader :double_insertions, :ordered_doubles
    attr_accessor :trim_backtrace
    def initialize
      @double_insertions = HashWithObjectIdKey.new
      @ordered_doubles = []
      @trim_backtrace = false
    end

    def double_method_proxy(creator, object, method_name=nil, &definition)
      if method_name && definition
        raise ArgumentError, "Cannot pass in a method name and a block"
      end
      proxy = DoubleMethodProxy.new(self, creator, object, &definition)
      return proxy unless method_name
      proxy.__send__(method_name)
    end

    # Creates a DoubleCreator.
    def double_creator
      DoubleCreator.new(self)
    end

    # Creates and registers a Double to be verified.
    def double(double_insertion, definition = double_definition)
      double = Double.new(self, double_insertion, definition)
      double.definition.double = double
      double_insertion.register_double double
      double
    end

    def double_definition
      DoubleDefinition.new(self)
    end

    # Reuses or creates, if none exists, a DoubleInjection for the passed
    # in object and method_name.
    # When a DoubleInjection is created, it binds the dispatcher to the
    # object.
    def double_insertion(object, method_name)
      double_insertion = @double_insertions[object][method_name.to_sym]
      return double_insertion if double_insertion

      double_insertion = DoubleInjection.new(self, object, method_name.to_sym)
      @double_insertions[object][method_name.to_sym] = double_insertion
      double_insertion.bind
      double_insertion
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
      @double_insertions.each do |object, method_double_map|
        method_double_map.keys.each do |method_name|
          verify_double(object, method_name)
        end
      end
    end

    # Resets the registered Doubles and ordered Doubles
    def reset
      reset_ordered_doubles
      reset_double_insertions
    end

    # Verifies the DoubleInjection for the passed in object and method_name.
    def verify_double(object, method_name)
      @double_insertions[object][method_name].verify
    ensure
      reset_double object, method_name
    end

    # Resets the DoubleInjection for the passed in object and method_name.
    def reset_double(object, method_name)
      double_insertion = @double_insertions[object].delete(method_name)
      @double_insertions.delete(object) if @double_insertions[object].empty?
      double_insertion.reset
    end

    protected
    # Removes the ordered Doubles from the list
    def reset_ordered_doubles
      @ordered_doubles.clear
    end

    # Resets the registered Doubles for the next test run.
    def reset_double_insertions
      @double_insertions.each do |object, method_double_map|
        method_double_map.keys.each do |method_name|
          reset_double(object, method_name)
        end
      end
    end    
  end
end