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

    attr_reader :space, :subject
    include Errors

    def initialize(space)
      @space = space
      @strategy = nil
      @probe = false
      @instance_of = nil
    end
    
    def create!(subject, method_name, *args, &handler)
      @subject = subject
      @method_name = method_name
      @args = args
      @handler = handler
      @double = @space.double(@subject, method_name)
      @scenario = @space.scenario(@double)
      transform!
      @scenario
    end

#    def instance_of(subject=NO_SUBJECT_ARG, method_name=nil, &definition)
#      return self if subject === NO_SUBJECT_ARG
#      raise ArgumentError, "instance_of only accepts class objects" unless subject.is_a?(Class)
#      @instance_of = true
#      RR::Space.scenario_method_proxy(self, subject, method_name, &definition)
#    end

    # This method sets the Scenario to have a mock strategy. A mock strategy
    # sets the default state of the Scenario to expect the method call
    # with arguments exactly one time. The Scenario's expectations can be
    # changed.
    #
    # This method can be chained with probe.
    #   mock.probe(subject).method_name_1
    #   or
    #   probe.mock(subject).method_name_1
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
      return self if subject === NO_SUBJECT_ARG
      RR::Space.scenario_method_proxy(self, subject, method_name, &definition)
    end

    # This method sets the Scenario to have a stub strategy. A stub strategy
    # sets the default state of the Scenario to expect the method call
    # with any arguments any number of times. The Scenario's
    # expectations can be changed.
    #
    # This method can be chained with probe.
    #   stub.probe(subject).method_name_1
    #   or
    #   probe.stub(subject).method_name_1
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
      return self if subject === NO_SUBJECT_ARG
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
      probe_when_do_not_call_error! if @probe
      @strategy = :do_not_call
      return self if subject === NO_SUBJECT_ARG
      RR::Space.scenario_method_proxy(self, subject, method_name, &definition)
    end
    alias_method :dont_call, :do_not_call
    alias_method :do_not_allow, :do_not_call
    alias_method :dont_allow, :do_not_call

    # This method add probe capabilities to the Scenario. probe can be called
    # with mock or stub.
    #
    #   mock.probe(controller.template).render(:partial => "my/socks")
    #
    #   stub.probe(controller.template).render(:partial => "my/socks") do |html|
    #     html.should include("My socks are wet")
    #     html
    #   end
    #
    #   mock.probe(controller.template).render(:partial => "my/socks") do |html|
    #     html.should include("My socks are wet")
    #     "My new return value"
    #   end
    #
    # mock.probe also takes a block for definitions.
    #   mock.probe(subject) do
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
    #   mock.probe(controller.template).render(:partial => "my/socks") do |html|
    #     html.should include("My socks are wet")
    #     "My new return value"
    #   end
    def probe(subject=NO_SUBJECT_ARG, method_name=nil, &definition)
      probe_when_do_not_call_error! if @strategy == :do_not_call
      @probe = true
      return self if subject === NO_SUBJECT_ARG
      RR::Space.scenario_method_proxy(self, subject, method_name, &definition)
    end
    
    protected
    def transform!
      case @strategy
      when :mock; mock!
      when :stub; stub!
      when :do_not_call; do_not_call!
      else no_strategy_error!
      end
      
      if @probe
        probe!
      else
        reimplementation!
      end
    end

    def mock!
      @scenario.with(*@args).once
    end

    def stub!
      @scenario.any_number_of_times
      permissive_argument!
    end

    def do_not_call!
      @scenario.never
      permissive_argument!
      reimplementation!
    end

    def permissive_argument!
      if @args.empty?
        @scenario.with_any_args
      else
        @scenario.with(*@args)
      end
    end

    def reimplementation!
      @scenario.returns(&@handler)
    end
    
    def probe!
      @scenario.implemented_by_original_method
      @scenario.after_call(&@handler) if @handler
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

    def probe_when_do_not_call_error!
      raise(
        ScenarioDefinitionError,
        "Scenarios cannot be probed when using do_not_call strategy"
      )
    end
  end
end
