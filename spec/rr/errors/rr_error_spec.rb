require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Errors
    describe RRError do
      describe "#backtrace" do
        before do
          @original_trim_backtrace = RR.trim_backtrace
        end
        after do
          RR.trim_backtrace = @original_trim_backtrace
        end

        it "does not include the rr library files when trim_backtrace is true" do
          RR.trim_backtrace = true

          error = nil
          begin
            obj = Object.new
            mock(obj).foobar
            RR.verify_double(obj, :foobar)
          rescue RRError=> e
            error = e
          end
          backtrace = error.backtrace.join("\n")

          backtrace.should_not include("lib/rr")
        end

        it "includes the rr library files when trim_backtrace is false" do
          RR.trim_backtrace = false

          error = nil
          begin
            obj = Object.new
            mock(obj).foobar
            RR.verify_double(obj, :foobar)
          rescue RRError=> e
            error = e
          end
          backtrace = error.backtrace.join("\n")

          backtrace.should include("lib/rr")
        end

        it "returns custom backtrace when backtrace is set" do
          error = RRError.new
          custom_backtrace = caller
          error.backtrace = custom_backtrace
          error.backtrace.should == custom_backtrace
        end

        it "returns normal backtrace when backtrace is not set" do
          error = nil
          expected_line = __LINE__ + 2
          begin
            raise RRError
          rescue RRError => e
            error = e
          end
          error.backtrace.first.should include(__FILE__)
          error.backtrace.first.should include(expected_line.to_s)
        end
      end
    end
  end
end