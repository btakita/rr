require "spec/spec_helper"

module RR
  module Adapters
    describe InstanceMethods, :shared => true do
      before do
        extend RR::Adapters::InstanceMethods
      end
    end
  end
end