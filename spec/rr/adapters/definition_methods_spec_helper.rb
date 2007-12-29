require "spec/spec_helper"

module RR
  module Adapters
    describe DefinitionMethods, :shared => true do
      before do
        extend RR::Adapters::DefinitionMethods
      end
    end
  end
end