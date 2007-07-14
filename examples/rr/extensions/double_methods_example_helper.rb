require "examples/example_helper"

module RR
module Extensions
  describe DoubleMethods, :shared => true do
    before do
      extend RR::Extensions::DoubleMethods
    end
  end
end
end