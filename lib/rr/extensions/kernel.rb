module Kernel
  def mock(*args)
    RR::MockCreationProxy.new(RR::Space.instance, *args)
  end

  def stub(*args)
    RR::StubCreationProxy.new(RR::Space.instance, *args)
  end

  def probe(*args)
    RR::ProbeCreationProxy.new(RR::Space.instance, *args)
  end
end
