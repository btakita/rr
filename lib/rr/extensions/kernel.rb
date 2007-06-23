module Kernel
  def mock(subject, &definition)
    RR::Space.instance.create_mock_creator(subject, &definition)
  end

  def stub(subject)
    RR::Space.instance.create_stub_creator(subject)
  end

  def probe(subject)
    RR::Space.instance.create_probe_creator(subject)
  end
end
