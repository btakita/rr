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
    #   probe(object).to_s
    def probe(subject, &definition)
      RR::Space.instance.create_probe_creator(subject, &definition)
    end

    def anything
      RR::Expectations::WildcardMatchers::Anything.new
    end

    def is_a(klass)
      RR::Expectations::WildcardMatchers::IsA.new(klass)
    end

    def numeric
      RR::Expectations::WildcardMatchers::Numeric.new
    end

    def boolean
      RR::Expectations::WildcardMatchers::Boolean.new
    end

    def duck_type(*args)
      RR::Expectations::WildcardMatchers::DuckType.new(*args)
    end

    instance_methods.each do |name|
      alias_method "rr_#{name}", name
    end
  end
end
end
