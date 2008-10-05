require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Adapters
    describe Rspec do
      describe "#trim_backtrace" do
        it "does not set trim_backtrace" do
          RR.trim_backtrace.should == false
        end
      end

      describe ".included" do
        it "does not add backtrace identifier twice" do
          length = ::Spec::Runner::QuietBacktraceTweaker::IGNORE_PATTERNS.length
          class << Object.new
            include ::RR::Adapters::Rspec
          end
          ::Spec::Runner::QuietBacktraceTweaker::IGNORE_PATTERNS.length.should == length
        end
      end

      describe " backtrace tweaking" do
        attr_reader :original_rspec_options, :error, :output
        before do
          @original_rspec_options = Spec::Runner.options
          @error = StringIO.new("")
          @output = StringIO.new("")
          Spec::Runner.use(::Spec::Runner::Options.new(error, output))
        end

        after do
          Spec::Runner.use(original_rspec_options)
        end

        it "hides rr library from the backtrace by default" do
          subject = @subject
          example_group = Class.new(::Spec::Example::ExampleGroup) do
            describe "Example"

            it("hides RR framework in backtrace") do
              mock(subject).foobar()
              RR.verify_double(subject, :foobar)
            end
          end

          Spec::Runner.options.run_examples

          output.string.should_not be_empty
          output.string.should_not include("lib/rr")
        end
      end
    end
  end
end
