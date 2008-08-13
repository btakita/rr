# require "spec/spec_helper"

module RR
  module Adapters
    describe RRMethods, :shared => true do
      before do
        extend RR::Adapters::RRMethods
      end
    end
  end
end