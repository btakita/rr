module RR
  # RR::ScenarioCreator provides a strategies to create a Scenario.
  # The strategies are:
  # * mock
  # * stub
  # * do_not_call
  #
  # Probing can also be added.
  class ScenarioCreator
    NO_SUBJECT_ARG = Object.new

    attr_reader :space
    include Errors

    def initialize(space)
      @space = space
      @strategy = nil
      @proxy = false
      @instance_of = nil
      @instance_of_method_name = nil
    end
    
    # This method sets the Scenario to have a mock strategy. A mock strategy
    # sets the default state of the Scenario to expect the method call
    # with arguments exactly one time. The Scenario's expectations can be
    # changed.
    #
    # This method can be chained with proxy.
    #   mock.proxy(subject).method_name_1
    #   or
    #   proxy.mock(subject).method_name_1
    #
    # When passed the subject, a ScenarioMethodProxy is returned. Passing
    # a method with arguments to the proxy will set up expectations that
    # the a call to the subject's method with the arguments will happen.
    #   mock(subject).method_name_1 {return_value_1}
    #   mock(subject).method_name_2(arg1, arg2) {return_value_2}
    #
    # When passed the subject and the method_name, this method returns
    # a mock Scenario with the method already set.
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
      strategy_error! if @strategy
      @strategy = :mock
      return self if subject.__id__ === NO_SUBJECT_ARG.__id__
      RR::Space.scenario_method_proxy(self, subject, method_name, &definition)
    end

    # This method sets the Scenario to have a stub strategy. A stub strategy
    # sets the default state of the Scenario to expect the method call
    # with any arguments any number of times. The Scenario's
    # expectations can be changed.
    #
    # This method can be chained with proxy.
    #   stub.proxy(subject).method_name_1
    #   or
    #   proxy.stub(subject).method_name_1
    #
    # When passed the subject, a ScenarioMethodProxy is returned. Passing
    # a method with arguments to the proxy will set up expectations that
    # the a call to the subject's method with the arguments will happen,
    # and return the prescribed value.
    #   stub(subject).method_name_1 {return_value_1}
    #   stub(subject).method_name_2(arg_1, arg_2) {return_value_2}
    #
    # When passed the subject and the method_name, this method returns
    # a stub Scenario with the method already set.
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
      strategy_error! if @strategy
      @strategy = :stub
      return self if subject.__id__ === NO_SUBJECT_ARG.__id__
      RR::Space.scenario_method_proxy(self, subject, method_name, &definition)
    end

    # This method sets the Scenario to have a do_not_call strategy.
    # A do_not_call strategy sets the default state of the Scenario
    # to expect never to be called. The Scenario's expectations can be
    # changed.
    #
    # The following example sets the expectation that subject.method_name
    # will never be called with arg1 and arg2.
    #
    #   do_not_allow(subject).method_name(arg1, arg2)
    #
    # do_not_call also supports a block sytnax.
    #    do_not_call(subject) do |m|
    #      m.method1 # Do not allow method1 with any arguments
    #      m.method2(arg1, arg2) # Do not allow method2 with arguments arg1 and arg2
    #      m.method3.with_no_args # Do not allow method3 with no arguments
    #    end
    def do_not_call(subject=NO_SUBJECT_ARG, method_name=nil, &definition)
      strategy_error! if @strategy
      proxy_when_do_not_call_error! if @proxy
      @strategy = :do_not_call
      return self if subject.__id__ === NO_SUBJECT_ARG.__id__
      RR::Space.scenario_method_proxy(self, subject, method_name, &definition)
    end
    alias_method :dont_call, :do_not_call
    alias_method :do_not_allow, :do_not_call
    alias_method :dont_allow, :do_not_call

    # This method add proxy capabilities to the Scenario. proxy can be called
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
    # Passing a block to the Scenario (after the method name and arguments)
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
      proxy_when_do_not_call_error! if @strategy == :do_not_call
      @proxy = true
      return self if subject.__id__ === NO_SUBJECT_ARG.__id__
      RR::Space.scenario_method_proxy(self, subject, method_name, &definition)
    end
    alias_method :probe, :proxy

    # Calling instance_of will cause all instances of the passed in Class
    # to have the Scenario defined.
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
      @instance_of = true
      return self if subject === NO_SUBJECT_ARG
      raise ArgumentError, "instance_of only accepts class objects" unless subject.is_a?(Class)
      RR::Space.scenario_method_proxy(self, subject, method_name, &definition)
    end

    def create!(subject, method_name, *args, &handler)
      @args = args
      @handler = handler
      if @instance_of
        setup_class_probing_instances(subject, method_name)
      else
        setup_scenario(subject, method_name)
      end
      transform!
      @definition
    end
    
    protected
    def setup_scenario(subject, method_name)
      @double_insertion = @space.double_insertion(subject, method_name)
      @scenario = @space.scenario(@double_insertion)
      @definition = @scenario.definition
    end

    def setup_class_probing_instances(subject, method_name)
      class_double = @space.double_insertion(subject, :new)
      class_scenario = @space.scenario(class_double)

      instance_method_name = method_name

      @definition = @space.scenario_definition
      class_handler = proc do |return_value|
        double_insertion = @space.double_insertion(return_value, instance_method_name)
        @space.scenario(double_insertion, @definition)
        return_value
      end

      builder = ScenarioDefinitionBuilder.new(
        class_scenario.definition,
        [],
        class_handler
      )
      builder.stub!
      builder.proxy!
    end

    def transform!
      builder = ScenarioDefinitionBuilder.new(@definition, @args, @handler)

      case @strategy
      when :mock; builder.mock!
      when :stub; builder.stub!
      when :do_not_call; builder.do_not_call!
      else no_strategy_error!
      end
      
      if @proxy
        builder.proxy!
      else
        builder.reimplementation!
      end
    end

    def strategy_error!
      raise(
        ScenarioDefinitionError,
        "This Scenario already has a #{@strategy} strategy"
      )
    end

    def no_strategy_error!
      raise(
        ScenarioDefinitionError,
        "This Scenario has no strategy"
      )
    end

    def proxy_when_do_not_call_error!
      raise(
        ScenarioDefinitionError,
        "Scenarios cannot be proxied when using do_not_call strategy"
      )
    end
  end
end
