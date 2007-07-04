require "spec/mocks"
require "rr"

module RR
  module Adapters
    module TestUnit
      include RR::Extensions::DoubleMethods
    end
  end
end
