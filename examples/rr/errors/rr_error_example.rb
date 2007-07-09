dir = File.dirname(__FILE__)
require "#{dir}/../../example_helper"

module RR
module Errors
  describe RRError, "#backtrace" do
    before do
      @original_trim_backtrace = RR::Space.trim_backtrace
    end
    after do
      RR::Space.trim_backtrace = @original_trim_backtrace
    end

    it "does not include the rr library files when trim_backtrace is true" do
      RR::Space.trim_backtrace = true

      error = nil
      begin
        obj = Object.new
        mock(obj).foobar
        RR::Space.verify_double(obj, :foobar)
      rescue RRError=> e
        error = e
      end
      backtrace = error.backtrace.join("\n")

      backtrace.should_not include("lib/rr")
    end

    it "includes the rr library files when trim_backtrace is false" do
      RR::Space.trim_backtrace = false

      error = nil
      begin
        obj = Object.new
        mock(obj).foobar
        RR::Space.verify_double(obj, :foobar)
      rescue RRError=> e
        error = e
      end
      backtrace = error.backtrace.join("\n")

      backtrace.should include("lib/rr")
    end
  end
end
end