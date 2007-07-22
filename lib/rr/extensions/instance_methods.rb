module RR
module Extensions
  module InstanceMethods
    # Verifies all the Double objects have met their
    # TimesCalledExpectations.
    def verify
      RR::Space.instance.verify_doubles
    end

    # Resets the registered Doubles and ordered Scenarios
    def reset
      RR::Space.instance.reset
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
    # the a call to the subject's method with the arguments will happen,
    # and return the prescribed value.
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
    def mock(subject=ScenarioCreator::NO_SUBJECT_ARG, method_name=nil, &definition)
      creator = RR::Space.scenario_creator
      creator.mock(subject, method_name, &definition)
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
    def stub(subject=ScenarioCreator::NO_SUBJECT_ARG, method_name=nil, &definition)
      creator = RR::Space.scenario_creator
      creator.stub(subject, method_name, &definition)
    end

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
    def probe(subject=ScenarioCreator::NO_SUBJECT_ARG, method_name=nil, &definition)
      creator = RR::Space.scenario_creator
      creator.probe(subject, method_name, &definition)
    end

    # RR::DoNotAllowCreator uses RR::DoNotAllowCreator#method_missing to create
    # a Scenario that expects never to be called.
    #
    # The following example mocks method_name with arg1 and arg2
    # returning return_value.
    #
    #   do_not_allow(subject).method_name(arg1, arg2) { return_value }
    #
    # The DoNotAllowCreator also supports a block sytnax.
    #
    #    do_not_allow(subject) do |m|
    #      m.method1 # Do not allow method1 with any arguments
    #      m.method2(arg1, arg2) # Do not allow method2 with arguments arg1 and arg2
    #      m.method3.with_no_args # Do not allow method3 with no arguments
    #    end
    def do_not_call(subject=ScenarioCreator::NO_SUBJECT_ARG, method_name=nil, &definition)
      creator = RR::Space.scenario_creator
      creator.do_not_call(subject, method_name, &definition)
    end
    alias_method :dont_call, :do_not_call
    alias_method :do_not_allow, :do_not_call
    alias_method :dont_allow, :do_not_call

    # Returns a AnyTimesMatcher. This is meant to be passed in as an argument
    # to Scenario#times.
    #
    #   mock(object).method_name(anything).times(any_times) {return_value}
    def any_times
      TimesCalledMatchers::AnyTimesMatcher.new
    end

    # Sets up an Anything wildcard ArgumentEqualityExpectation
    # that succeeds when passed any argument.
    #   mock(object).method_name(anything) {return_value}
    #   object.method_name("an arbitrary value") # passes
    def anything
      RR::WildcardMatchers::Anything.new
    end

    # Sets up an IsA wildcard ArgumentEqualityExpectation
    # that succeeds when passed an argument of a certain type.
    #   mock(object).method_name(is_a(String)) {return_value}
    #   object.method_name("A String") # passes
    def is_a(klass)
      RR::WildcardMatchers::IsA.new(klass)
    end

    # Sets up an Numeric wildcard ArgumentEqualityExpectation
    # that succeeds when passed an argument that is ::Numeric.
    #   mock(object).method_name(numeric) {return_value}
    #   object.method_name(99) # passes
    def numeric
      RR::WildcardMatchers::Numeric.new
    end

    # Sets up an Boolean wildcard ArgumentEqualityExpectation
    # that succeeds when passed an argument that is a ::Boolean.
    #   mock(object).method_name(boolean) {return_value}
    #   object.method_name(false) # passes
    def boolean
      RR::WildcardMatchers::Boolean.new
    end

    # Sets up a DuckType wildcard ArgumentEqualityExpectation
    # that succeeds when passed the argument implements the methods.
    #   arg = Object.new
    #   def arg.foo; end
    #   def arg.bar; end
    #   mock(object).method_name(duck_type(:foo, :bar)) {return_value}
    #   object.method_name(arg) # passes
    def duck_type(*args)
      RR::WildcardMatchers::DuckType.new(*args)
    end

    instance_methods.each do |name|
      alias_method "rr_#{name}", name
    end
  end
end
end
