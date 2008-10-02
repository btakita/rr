require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Expectations
    describe ArgumentEqualityExpectation do
      context "when matching anything" do
        attr_reader :expectation
        before do
          @expectation = ArgumentEqualityExpectation.new(anything)
        end
      end
    end
  end
end
