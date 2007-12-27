require "spec/example_helper"

describe RR::Adapters::Rspec, "#trim_backtrace" do
  it "does not set trim_backtrace" do
    RR::Space.trim_backtrace.should == false
  end  
end

describe RR::Adapters::Rspec, ".included" do
  it "does not add backtrace identifier twice" do
    length = ::Spec::Runner::QuietBacktraceTweaker::IGNORE_PATTERNS.length
    class << Object.new
      include ::RR::Adapters::Rspec
    end
    ::Spec::Runner::QuietBacktraceTweaker::IGNORE_PATTERNS.length.should == length
  end
end

describe RR::Adapters::Rspec, " backtrace tweaking" do
  attr_reader :original_rspec_options, :output
  before do
    @original_rspec_options = $rspec_options
    @output = StringIO.new("")
    $rspec_options = ::Spec::Runner::Options.new(output, StringIO.new)
  end

  after do
    $rspec_options = original_rspec_options
  end

  it "hides rr library from the backtrace by default" do
    subject = @subject
    Class.new(::Spec::Example::ExampleGroup) do
      describe "Example"

      it("hides RR framework in backtrace") do
        mock(subject).foobar()
        RR::Space::instance.verify_double(subject, :foobar)
      end
    end

    $rspec_options.run_examples
    
    output.string.should_not include("lib/rr")
  end
end