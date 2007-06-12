module Kernel
  def mock(*args)
    RR::Space.instance.create_mock_creator(*args)
  end

  def stub(*args)
    RR::Space.instance.create_stub_creator(*args)
  end

  def probe(*args)
    RR::Space.instance.create_probe_creator(*args)
  end
end
