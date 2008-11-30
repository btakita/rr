require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe RR do
  attr_reader :subject
  before do
    @subject = Object.new
  end

  describe "#mock" do
    it "creates a mock DoubleInjection Double" do
      mock(subject).foobar(1, 2) {:baz}
      subject.foobar(1, 2).should == :baz
    end
  end

  describe "#stub" do
    it "creates a stub DoubleInjection Double" do
      stub(subject).foobar {:baz}
      subject.foobar("any", "thing").should == :baz
    end
  end

  describe "#mock and #proxy" do
    before do
      def subject.foobar
        :baz
      end
    end

    it "creates a proxy DoubleInjection Double" do
      mock.proxy(subject).foobar
      subject.foobar.should == :baz
    end
  end

  describe "#stub and #proxy" do
    before do
      def subject.foobar
        :baz
      end
    end

    it "creates a proxy DoubleInjection Double" do
      stub.proxy(subject).foobar
      subject.foobar.should == :baz
    end
  end

  describe "#stub and #proxy" do
    before do
      def subject.foobar
        :baz
      end
    end

    it "creates a proxy DoubleInjection Double" do
      stub.proxy(subject).foobar
      subject.foobar.should == :baz
    end
  end

  describe "spies" do
    it "validates that a Double was called after it was called" do
      stub(subject).foobar
      subject.foobar(1, 2)

      subject.should have_received.foobar(1, 2)
      lambda do
        subject.should have_received.foobar(1, 2, 3)
      end.should raise_error(Spec::Expectations::ExpectationNotMetError)
    end
  end

  it "creates an invocation matcher with a method name" do
    method  = :test
    matcher = 'fake'
    mock(RR::Adapters::Rspec::InvocationMatcher).new(method) { matcher }
    have_received(method).should == matcher
  end

  it "creates an invocation matcher without a method name" do
    matcher = 'fake'
    mock(RR::Adapters::Rspec::InvocationMatcher).new(nil) { matcher }
    have_received.should == matcher
  end
end
