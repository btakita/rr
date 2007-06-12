module Kernel
  def mock(*args)
    RR::MockCreator.new(RR::Space.instance, *args)
  end

  def stub(*args)
    RR::StubCreator.new(RR::Space.instance, *args)
  end

  def probe(*args)
    RR::ProbeCreator.new(RR::Space.instance, *args)
  end
end
