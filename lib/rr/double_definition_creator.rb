module RR
  class DoubleDefinitionCreator # :nodoc
    NO_SUBJECT_ARG = Object.new

    attr_reader :space
    include Errors

    def initialize(space)
      @space = space
      @strategy = nil
      @using_proxy_strategy = false
      @instance_of_called = nil
    end
    
    def mock(subject=NO_SUBJECT_ARG, method_name=nil, &definition) # :nodoc
      verify_no_strategy
      @strategy = :mock
      return self if subject.__id__ === NO_SUBJECT_ARG.__id__
      RR.double_definition_creator_proxy(self, subject, method_name, &definition)
    end

    def stub(subject=NO_SUBJECT_ARG, method_name=nil, &definition) # :nodoc
      verify_no_strategy
      @strategy = :stub
      return self if subject.__id__ === NO_SUBJECT_ARG.__id__
      RR.double_definition_creator_proxy(self, subject, method_name, &definition)
    end

    def dont_allow(subject=NO_SUBJECT_ARG, method_name=nil, &definition) # :nodoc
      verify_no_strategy
      proxy_when_dont_allow_error if @using_proxy_strategy
      @strategy = :dont_allow
      return self if subject.__id__ === NO_SUBJECT_ARG.__id__
      RR.double_definition_creator_proxy(self, subject, method_name, &definition)
    end
    alias_method :do_not_allow, :dont_allow
    alias_method :dont_call, :dont_allow
    alias_method :do_not_call, :dont_allow

    def proxy(subject=NO_SUBJECT_ARG, method_name=nil, &definition) # :nodoc
      proxy_when_dont_allow_error if @strategy == :dont_allow
      @using_proxy_strategy = true
      return self if subject.__id__ === NO_SUBJECT_ARG.__id__
      RR.double_definition_creator_proxy(self, subject, method_name, &definition)
    end
    alias_method :probe, :proxy

    def instance_of(subject=NO_SUBJECT_ARG, method_name=nil, &definition) # :nodoc
      @instance_of_called = true
      return self if subject === NO_SUBJECT_ARG
      raise ArgumentError, "instance_of only accepts class objects" unless subject.is_a?(Class)
      RR.double_definition_creator_proxy(self, subject, method_name, &definition)
    end

    def create(subject, method_name, *args, &handler)
      @args = args
      @handler = handler
      if @instance_of_called
        setup_doubles_for_class_instances(subject, method_name)
      else
        setup_double(subject, method_name)
      end
      transform
      @definition
    end
    
    protected
    def setup_double(subject, method_name)
      @double_injection = @space.double_injection(subject, method_name)
      @double = @space.double(@double_injection)
      @definition = @double.definition
    end

    def setup_doubles_for_class_instances(subject, method_name)
      class_double = @space.double_injection(subject, :new)
      class_double = @space.double(class_double)

      instance_method_name = method_name

      @definition = @space.double_definition
      class_handler = proc do |return_value|
        double_injection = @space.double_injection(return_value, instance_method_name)
        @space.double(double_injection, @definition)
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
      builder.__send__(@strategy)

      if @using_proxy_strategy
        builder.proxy
      else
        builder.reimplementation
      end
    end

    def verify_no_strategy
      strategy_already_defined_error if @strategy
    end

    def strategy_already_defined_error
      raise(
        DoubleDefinitionError,
        "This Double already has a #{@strategy} strategy"
      )
    end

    def verify_strategy
      no_strategy_error unless @strategy
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
