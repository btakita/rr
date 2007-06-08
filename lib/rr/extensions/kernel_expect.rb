module Kernel
  def mock(*args)
    RR::ExpectationProxy.new(RR::Space.instance, *args)
  end
end
