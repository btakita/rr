module RR
module Extensions
  module DoubleMethods
    def mock(subject, &definition)
      RR::Space.instance.create_mock_creator(subject, &definition)
    end

    def stub(subject, &definition)
      RR::Space.instance.create_stub_creator(subject, &definition)
    end

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
  end  
end
end
