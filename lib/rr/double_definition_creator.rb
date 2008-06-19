module RR
  class DoubleDefinitionCreator # :nodoc
    NO_SUBJECT_ARG = Object.new

    attr_reader :space
    include Errors

    def initialize(space)
      @space = space
      @core_strategy = nil
      @using_proxy_strategy = false
      @using_instance_of_strategy = nil
    end
    
    def mock(subject=NO_SUBJECT_ARG, method_name=nil, &definition) # :nodoc
      add_strategy(subject, method_name, definition) do
        set_core_strategy :mock
      end
    end

    def stub(subject=NO_SUBJECT_ARG, method_name=nil, &definition) # :nodoc
      add_strategy(subject, method_name, definition) do
        set_core_strategy :stub
      end
    end

    def dont_allow(subject=NO_SUBJECT_ARG, method_name=nil, &definition) # :nodoc
      add_strategy(subject, method_name, definition) do
        set_core_strategy :dont_allow
      end
    end
    alias_method :do_not_allow, :dont_allow
    alias_method :dont_call, :dont_allow
    alias_method :do_not_call, :dont_allow

    def proxy(subject=NO_SUBJECT_ARG, method_name=nil, &definition) # :nodoc
      add_strategy(subject, method_name, definition) do
        proxy_when_dont_allow_error if @core_strategy == :dont_allow
        @using_proxy_strategy = true
      end
    end
    alias_method :probe, :proxy

    def instance_of(subject=NO_SUBJECT_ARG, method_name=nil, &definition) # :nodoc
      if subject != NO_SUBJECT_ARG && !subject.is_a?(Class)
        raise ArgumentError, "instance_of only accepts class objects" unless subject.is_a?(Class)
      end
      add_strategy(subject, method_name, definition) do
        @using_instance_of_strategy = true
        return self if subject === NO_SUBJECT_ARG
      end
    end

    def create(subject, method_name, *args, &handler)
      @args = args
      @handler = handler
      if @using_instance_of_strategy
        setup_doubles_for_class_instances(subject, method_name)
      else
        setup_double(subject, method_name)
      end
      transform
      @definition
    end
    
    protected
    def add_strategy(subject, method_name, definition)
      if method_name && definition
        raise ArgumentError, "Cannot pass in a method name and a block"
      end
      yield
      if subject.__id__ === NO_SUBJECT_ARG.__id__
        self
      elsif method_name
        create subject, method_name, &definition
      else
        DoubleDefinitionCreatorProxy.new(self, subject, &definition)
      end
    end

    def set_core_strategy(strategy)
      verify_no_core_strategy
      @core_strategy = strategy
      proxy_when_dont_allow_error if strategy == :dont_allow && @using_proxy_strategy
    end

    def setup_double(subject, method_name)
      @double_injection = @space.double_injection(subject, method_name)
      @double = Double.new(@double_injection)
      @definition = @double.definition
    end

    def setup_doubles_for_class_instances(subject, method_name)
      class_double = @space.double_injection(subject, :new)
      class_double = Double.new(class_double)

      instance_method_name = method_name

      @definition = DoubleDefinition.new
      class_handler = proc do |return_value|
        double_injection = @space.double_injection(return_value, instance_method_name)
        Double.new(double_injection, @definition)
        return_value
      end

      builder = DoubleDefinitionBuilder.new(
        class_double.definition,
        [],
        class_handler
      )
      builder.stub
      builder.proxy
    end

    def transform
      builder = DoubleDefinitionBuilder.new(@definition, @args, @handler)

      verify_strategy
      builder.__send__(@core_strategy)

      if @using_proxy_strategy
        builder.proxy
      else
        builder.reimplementation
      end
    end

    def verify_no_core_strategy
      strategy_already_defined_error if @core_strategy
    end

    def strategy_already_defined_error
      raise(
        DoubleDefinitionError,
        "This Double already has a #{@core_strategy} strategy"
      )
    end

    def verify_strategy
      no_strategy_error unless @core_strategy
    end

    def no_strategy_error
      raise(
        DoubleDefinitionError,
        "This Double has no strategy"
      )
    end

    def proxy_when_dont_allow_error
      raise(
        DoubleDefinitionError,
        "Doubles cannot be proxied when using dont_allow strategy"
      )
    end
  end
end
