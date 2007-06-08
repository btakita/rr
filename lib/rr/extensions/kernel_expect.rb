module Kernel
  def expect(*args)
    RR::ExpectationProxy.new(RR::Space.instance, *args)
  end
end
