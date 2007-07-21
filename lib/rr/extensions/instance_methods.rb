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

    # When passed the object, this method returns a MockCreator
    # that generates a Double Scenario that acts like a mock.
    #   mock(object).method_name(arg1, arg2) {return_value}
    #
    # When passed the object and the method_name, this method returns
    # a mock Scenario with the method already set.
    def mock(object, method_name=nil, &definition)
      RR::Space.instance.mock_creator(object, method_name, &definition)
    end

    # When passed the object, this method returns a StubCreator
    # that generates a Double Scenario that acts like a stub.
    #   stub(object).method_name {return_value}
    #
    # When passed the object and the method_name, this method returns
    # a stub Scenario with the method already set.
    def stub(subject, method_name=nil, &definition)
      RR::Space.instance.stub_creator(subject, method_name, &definition)
    end

    # Sets up a MockProbeCreator that generates a Double Scenario that
    # acts like mock verifications while calling the actual method.
    #
    #   mock_probe(controller.template).render(:partial => "my/socks")
    #
    # Passing a block allows you to intercept the return value.
    # The return value can be modified, validated, and/or overridden by
    # passing in a block. The return value of the block will replace
    # the actual return value.
    #
    #   mock_probe(controller.template).render(:partial => "my/socks") do |html|
    #     html.should include("My socks are wet")
    #     "My new return value"
    #   end
    def mock_probe(subject, &definition)
      RR::Space.instance.create_mock_probe_creator(subject, &definition)
    end

    # Sets up a StubProbeCreator that generates a Double Scenario that
    # acts like mock verifications while calling the actual method.
    #
    #   mock_probe(User).new {|user| my_user}
    #
    # Passing a block allows you to intercept the return value.
    # The return value can be modified, validated, and/or overridden by
    # passing in a block. The return value of the block will replace
    # the actual return value.
    #
    #   mock_probe(controller.template).render(:partial => "my/socks") do |html|
    #     html.should include("My socks are wet")
    #     "My new return value"
    #   end
    def stub_probe(subject, &definition)
      RR::Space.instance.create_stub_probe_creator(subject, &definition)
    end

    # Same as mock_probe
    alias_method :probe, :mock_probe

    # Sets up a DoNotAllowCreator that generates a Double Scenario that
    # expects never to be called.
    #   do_not_allow(object).method_name
    def do_not_allow(subject, &definition)
      RR::Space.instance.create_do_not_allow_creator(subject, &definition)
    end
    alias_method :dont_allow, :do_not_allow

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
