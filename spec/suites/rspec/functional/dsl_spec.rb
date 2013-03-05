require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe RR do
  subject { Object.new }

  describe "#mock" do
    it "creates a mock DoubleInjection Double" do
      mock(subject).foobar(1, 2) {:baz}
      expect(subject.foobar(1, 2)).to eq :baz
    end
  end

  describe "#stub" do
    it "creates a stub DoubleInjection Double" do
      stub(subject).foobar {:baz}
      expect(subject.foobar("any", "thing")).to eq :baz
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
      expect(subject.foobar).to eq :baz
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
      expect(subject.foobar).to eq :baz
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
      expect(subject.foobar).to eq :baz
    end
  end

  describe "spies" do
    it "validates that a Double was called after it was called" do
      stub(subject).foobar
      subject.foobar(1, 2)

      expect(subject).to have_received.foobar(1, 2)
      expect {
        expect(subject).to have_received.foobar(1, 2, 3)
      }.to raise_error(Spec::Expectations::ExpectationNotMetError)
    end
  end

  it "creates an invocation matcher with a method name" do
    method  = :test
    matcher = 'fake'
    mock(RR::Adapters::Rspec::InvocationMatcher).new(method) { matcher }
    expect(have_received(method)).to eq matcher
  end

  it "creates an invocation matcher without a method name" do
    matcher = 'fake'
    mock(RR::Adapters::Rspec::InvocationMatcher).new(nil) { matcher }
    expect(have_received).to eq matcher
  end
end
