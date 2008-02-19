module RR
  # RR::DoubleCreator provides a strategies to create a Double.
  # The strategies are:
  # * mock
  # * stub
  # * proxy
  # * dont_allow
  class DoubleCreator
    NO_SUBJECT_ARG = Object.new

    attr_reader :space
    include Errors

    def initialize(space)
      @space = space
      @strategy = nil
      @proxy = false
      @instance_of_called = nil
    end
    
    # This method sets the Double to have a mock strategy. A mock strategy
    # sets the default state of the Double to expect the method call
    # with arguments exactly one time. The Double's expectations can be
    # changed.
    #
    # This method can be chained with proxy.
    #   mock.proxy(subject).method_name_1
    #   or
    #   proxy.mock(subject).method_name_1
    #
    # When passed the subject, a DoubleMethodProxy is returned. Passing
    # a method with arguments to the proxy will set up expectations that
    # the a call to the subject's method with the arguments will happen.
    #   mock(subject).method_name_1 {return_value_1}
    #   mock(subject).method_name_2(arg1, arg2) {return_value_2}
    #
    # When passed the subject and the method_name, this method returns
    # a mock Double with the method already set.
    #
    #   mock(subject, :method_name_1) {return_value_1}
    #   mock(subject, :method_name_2).with(arg1, arg2) {return_value_2}
    #
    # mock also takes a block for definitions.
    #   mock(subject) do
    #     method_name_1 {return_value_1}
    #     method_name_2(arg_1, arg_2) {return_value_2}
    #   end
    def mock(subject=NO_SUBJECT_ARG, method_name=nil, &definition)
      strategy_error if @strategy
      @strategy = :mock
      return self if subject.__id__ === NO_SUBJECT_ARG.__id__
      RR::Space.double_method_proxy(self, subject, method_name, &definition)
    end

    # This method sets the Double to have a stub strategy. A stub strategy
    # sets the default state of the Double to expect the method call
    # with any arguments any number of times. The Double's
    # expectations can be changed.
    #
    # This method can be chained with proxy.
    #   stub.proxy(subject).method_name_1
    #   or
    #   proxy.stub(subject).method_name_1
    #
    # When passed the subject, a DoubleMethodProxy is returned. Passing
    # a method with arguments to the proxy will set up expectations that
    # the a call to the subject's method with the arguments will happen,
    # and return the prescribed value.
    #   stub(subject).method_name_1 {return_value_1}
    #   stub(subject).method_name_2(arg_1, arg_2) {return_value_2}
    #
    # When passed the subject and the method_name, this method returns
    # a stub Double with the method already set.
    #
    #   mock(subject, :method_name_1) {return_value_1}
    #   mock(subject, :method_name_2).with(arg1, arg2) {return_value_2}
    #
    # stub also takes a block for definitions.
    #   stub(subject) do
    #     method_name_1 {return_value_1}
    #     method_name_2(arg_1, arg_2) {return_value_2}
    #   end
    def stub(subject=NO_SUBJECT_ARG, method_name=nil, &definition)
      strategy_error if @strategy
      @strategy = :stub
      return self if subject.__id__ === NO_SUBJECT_ARG.__id__
      RR::Space.double_method_proxy(self, subject, method_name, &definition)
    end

    # This method sets the Double to have a dont_allow strategy.
    # A dont_allow strategy sets the default state of the Double
    # to expect never to be called. The Double's expectations can be
    # changed.
    #
    # The following example sets the expectation that subject.method_name
    # will never be called with arg1 and arg2.
    #
    #   dont_allow(subject).method_name(arg1, arg2)
    #
    # dont_allow also supports a block sytnax.
    #    dont_allow(subject) do |m|
    #      m.method1 # Do not allow method1 with any arguments
    #      m.method2(arg1, arg2) # Do not allow method2 with arguments arg1 and arg2
    #      m.method3.with_no_args # Do not allow method3 with no arguments
    #    end
    def dont_allow(subject=NO_SUBJECT_ARG, method_name=nil, &definition)
      strategy_error if @strategy
      proxy_when_dont_allow_error if @proxy
      @strategy = :dont_allow
      return self if subject.__id__ === NO_SUBJECT_ARG.__id__
      RR::Space.double_method_proxy(self, subject, method_name, &definition)
    end
    alias_method :do_not_allow, :dont_allow
    alias_method :dont_call, :dont_allow
    alias_method :do_not_call, :dont_allow

    # This method add proxy capabilities to the Double. proxy can be called
    # with mock or stub.
    #
    #   mock.proxy(controller.template).render(:partial => "my/socks")
    #
    #   stub.proxy(controller.template).render(:partial => "my/socks") do |html|
    #     html.should include("My socks are wet")
    #     html
    #   end
    #
    #   mock.proxy(controller.template).render(:partial => "my/socks") do |html|
    #     html.should include("My socks are wet")
    #     "My new return value"
    #   end
    #
    # mock.proxy also takes a block for definitions.
    #   mock.proxy(subject) do
    #     render(:partial => "my/socks")
    #
    #     render(:partial => "my/socks") do |html|
    #       html.should include("My socks are wet")
    #       html
    #     end
    #
    #     render(:partial => "my/socks") do |html|
    #       html.should include("My socks are wet")
    #       html
    #     end
    #
    #     render(:partial => "my/socks") do |html|
    #       html.should include("My socks are wet")
    #       "My new return value"
    #     end
    #   end
    #
    # Passing a block to the Double (after the method name and arguments)
    # allows you to intercept the return value.
    # The return value can be modified, validated, and/or overridden by
    # passing in a block. The return value of the block will replace
    # the actual return value.
    #
    #   mock.proxy(controller.template).render(:partial => "my/socks") do |html|
    #     html.should include("My socks are wet")
    #     "My new return value"
    #   end
    def proxy(subject=NO_SUBJECT_ARG, method_name=nil, &definition)
      proxy_when_dont_allow_error if @strategy == :dont_allow
      @proxy = true
      return self if subject.__id__ === NO_SUBJECT_ARG.__id__
      RR::Space.double_method_proxy(self, subject, method_name, &definition)
    end
    alias_method :probe, :proxy

    # Calling instance_of will cause all instances of the passed in Class
    # to have the Double defined.
    #
    # The following example mocks all User's valid? method and return false. 
    #   mock.instance_of(User).valid? {false}
    #
    # The following example mocks and proxies User#projects and returns the
    # first 3 projects.
    #   mock.instance_of(User).projects do |projects|
    #     projects[0..2]
    #   end
    def instance_of(subject=NO_SUBJECT_ARG, method_name=nil, &definition)
      @instance_of_called = true
      return self if subject === NO_SUBJECT_ARG
      raise ArgumentError, "instance_of only accepts class objects" unless subject.is_a?(Class)
      RR::Space.double_method_proxy(self, subject, method_name, &definition)
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

      case @strategy
      when :mock; builder.mock
      when :stub; builder.stub
      when :dont_allow; builder.dont_allow
      else no_strategy_error
      end
      
      if @proxy
        builder.proxy
      else
        builder.reimplementation
      end
    end

    def strategy_error
      raise(
        DoubleDefinitionError,
        "This Double already has a #{@strategy} strategy"
      )
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
