require "examples/example_helper"

describe RR, " backtrace tweaking" do
  it "hides rr library from the backtrace by default" do
    output = StringIO.new("")
    backtrace_tweaker = ::Spec::Runner::QuietBacktraceTweaker.new
    formatter = ::Spec::Runner::Formatter::BaseTextFormatter.new(output)
    reporter = ::Spec::Runner::Reporter.new([formatter], backtrace_tweaker)

    behaviour = ::Spec::DSL::Behaviour.new("example") {}
    subject = @subject
    behaviour.it("hides RR framework in backtrace") do
      mock(subject).foobar()
      RR::Space::instance.verify_double(subject, :foobar)
    end

    reporter.add_behaviour(behaviour)

    behaviour.run(reporter)
    reporter.dump

    output.string.should_not include("lib/rr")
  end
end