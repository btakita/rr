require "spec/example_helper"

module RR
module Extensions
  describe InstanceMethods, :shared => true do
    before do
      extend RR::Extensions::InstanceMethods
    end
  end
end
end