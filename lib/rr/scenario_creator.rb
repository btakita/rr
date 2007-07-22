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

    def stub(subject=NO_SUBJECT_ARG, method_name=nil, &definition)
      strategy_error! if @strategy
      @strategy = :stub
      return self if subject === NO_SUBJECT_ARG
      RR::Space.scenario_method_proxy(self, subject, method_name, &definition)
    end

    def do_not_call(subject=NO_SUBJECT_ARG, method_name=nil, &definition)
      strategy_error! if @strategy
      probe_when_do_not_call_error! if @probe
      @strategy = :do_not_call
      return self if subject === NO_SUBJECT_ARG
      RR::Space.scenario_method_proxy(self, subject, method_name, &definition)
    end

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
