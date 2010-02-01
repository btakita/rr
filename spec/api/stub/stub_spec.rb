require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

class StubSpecFixture
  attr_reader :initialize_arguments

  def initialize(*args)
    @initialize_arguments = args
    yield if block_given?
    method_run_in_initialize
  end

  def method_run_in_initialize

  end
end

describe "stub" do
  attr_reader :subject
  before(:each) do
    @subject = Object.new
    extend RR::Adapters::RRMethods
  end

  after(:each) do
    RR.reset
  end

  describe "stub" do
    it "stubs via inline call" do
      stub(subject).to_s {"a value"}
      subject.to_s.should == "a value"
    end

    it "allows ordering" do
      stub(subject).to_s {"value 1"}.once.ordered
      stub(subject).to_s {"value 2"}.once.ordered

      subject.to_s.should == "value 1"
      subject.to_s.should == "value 2"
    end

    it "stubs via block with argument" do
      stub subject do |d|
        d.to_s {"a value"}
        d.to_sym {:crazy}
      end
      subject.to_s.should == "a value"
      subject.to_sym.should == :crazy
    end

    it "stubs via block without argument" do
      stub subject do
        to_s {"a value"}
        to_sym {:crazy}
      end
      subject.to_s.should == "a value"
      subject.to_sym.should == :crazy
    end

    it "stubs instance_of" do
      stub.instance_of(StubSpecFixture) do |o|
        o.to_s {"High Level Spec"}
      end
      StubSpecFixture.new.to_s.should == "High Level Spec"
    end

    it "stubs methods without letters" do
      stub(subject).__send__(:==) {:equality}
      (subject == 55).should == :equality
    end

    it "stubs methods invoked in #initialize while passing along the #initialize arg" do
      method_run_in_initialize_stubbed = false
      stub.instance_of(StubSpecFixture) do |o|
        o.method_run_in_initialize {method_run_in_initialize_stubbed = true}
      end
      StubSpecFixture.new
      method_run_in_initialize_stubbed.should be_true
    end

    it "passed the arguments and block passed to #initialize" do
      block_called = false
      stub.instance_of(StubSpecFixture) do |o|
        o.method_run_in_initialize
      end
      instance = StubSpecFixture.new(1, 2) {block_called = true}
      instance.initialize_arguments.should == [1, 2]
      block_called.should be_true
    end
  end
end
