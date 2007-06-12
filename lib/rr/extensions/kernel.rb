module Kernel
  def mock(*args)
    RR::MockCreationProxy.new(RR::Space.instance, *args)
  end

  def stub(*args)
    RR::StubExpectationProxy.new(RR::Space.instance, *args)
  end

  def probe(*args)
    RR::ProbeExpectationProxy.new(RR::Space.instance, *args)
  end
end
