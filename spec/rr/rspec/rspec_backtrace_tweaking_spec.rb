require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Adapters
    describe Rspec do
      describe "#trim_backtrace" do
        it "does not set trim_backtrace" do
          expect(RR.trim_backtrace).to eq false
        end
      end

      describe "backtrace tweaking" do
        it "hides rr library from the backtrace by default" do
          dir = File.dirname(__FILE__)
          output = `ruby #{dir}/rspec_backtrace_tweaking_spec_fixture.rb`
          output.should_not include("lib/rr")
        end
      end
    end
  end
end
