module RR
module Extensions
  module DoubleMethods
    # Sets up a MockCreator that generates a Double Scenario that
    # acts like a mock.
    #   mock(object).method_name(arg1, arg2) {return_value}
    def mock(subject, &definition)
      RR::Space.instance.create_mock_creator(subject, &definition)
    end

    # Sets up a StubCreator that generates a Double Scenario that
    # acts like a stub.
    #   stub(object).method_name {return_value}
    def stub(subject, &definition)
      RR::Space.instance.create_stub_creator(subject, &definition)
    end

    # Sets up a ProbeCreator that generates a Double Scenario that
    # acts like a probe.
    #   probe(controller.template).render(:partial => "my/socks")
    def probe(subject, &definition)
      RR::Space.instance.create_probe_creator(subject, &definition)
    end

    # Sets up a DoNotAllowCreator that generates a Double Scenario that
    # expects never to be called.
    #   do_not_allow(object).method_name
    def do_not_allow(subject, &definition)
      RR::Space.instance.create_do_not_allow_creator(subject, &definition)
    end
    alias_method :dont_allow, :do_not_allow

    # Sets up an Anything wildcard ArgumentEqualityError
    # that succeeds when passed any argument.
    #   mock(object).method_name(anything) {return_value}
    #   object.method_name("an arbitrary value") # passes
    def anything
      RR::WildcardMatchers::Anything.new
    end

    # Sets up an IsA wildcard ArgumentEqualityError
    # that succeeds when passed an argument of a certain type.
    #   mock(object).method_name(is_a(String)) {return_value}
    #   object.method_name("A String") # passes
    def is_a(klass)
      RR::WildcardMatchers::IsA.new(klass)
    end

    # Sets up an Numeric wildcard ArgumentEqualityError
    # that succeeds when passed an argument that is ::Numeric.
    #   mock(object).method_name(numeric) {return_value}
    #   object.method_name(99) # passes
    def numeric
      RR::WildcardMatchers::Numeric.new
    end

    # Sets up an Boolean wildcard ArgumentEqualityError
    # that succeeds when passed an argument that is a ::Boolean.
    #   mock(object).method_name(boolean) {return_value}
    #   object.method_name(false) # passes
    def boolean
      RR::WildcardMatchers::Boolean.new
    end

    # Sets up a DuckType wildcard ArgumentEqualityError
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
