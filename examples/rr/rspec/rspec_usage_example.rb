dir = File.dirname(__FILE__)
require "#{dir}/../../example_helper"

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

describe RR, "#mock" do
  before do
    @subject = Object.new
  end

  it "creates a mock Double Scenario" do
    mock(@subject).foobar(1, 2) {:baz}
    @subject.foobar(1, 2).should == :baz
  end
end

describe RR, "#stub" do
  before do
    @subject = Object.new
  end

  it "creates a stub Double Scenario" do
    stub(@subject).foobar {:baz}
    @subject.foobar("any", "thing").should == :baz
  end
end

describe RR, "#probe" do
  before do
    @subject = Object.new
    def @subject.foobar
      :baz
    end
  end

  it "creates a probe Double Scenario" do
    probe(@subject).foobar
    @subject.foobar.should == :baz
  end
end
