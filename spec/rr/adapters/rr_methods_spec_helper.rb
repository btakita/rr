# require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Adapters
    describe RRMethods, :shared => true do
      before do
        extend RR::Adapters::RRMethods
      end
    end
  end
end