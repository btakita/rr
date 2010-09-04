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

  it "stubs via inline call" do
    stub(subject).to_s {"a value"}
    subject.to_s.should == "a value"
  end

  describe ".once.ordered" do
    it "returns the values in the ordered called" do
      stub(subject).to_s {"value 1"}.once.ordered
      stub(subject).to_s {"value 2"}.once.ordered

      subject.to_s.should == "value 1"
      subject.to_s.should == "value 2"
    end
  end

  context "when the subject is a proxy for the object with the defined method" do
    it "stubs the method on the proxy object" do
      proxy_target = Class.new {def foobar; :original_foobar; end}.new
      proxy = Class.new do
        def initialize(target)
          @target = target
        end

        instance_methods.each do |m|
          unless m =~ /^_/ || m.to_s == 'object_id' || m.to_s == 'method_missing'
            alias_method "__blank_slated_#{m}", m
            undef_method m
          end
        end

        def method_missing(method_name, *args, &block)
          @target.send(method_name, *args, &block)
        end
      end.new(proxy_target)
      proxy.methods.should =~ proxy_target.methods

      stub(proxy).foobar {:new_foobar}
      proxy.foobar.should == :new_foobar
    end
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

  context "mock then stub" do
    it "stubs any calls not matching the mock" do
      mock(subject).foobar(3) {:baz3}
      stub(subject).foobar {:baz}
      subject.foobar(3).should == :baz3
      subject.foobar(4).should == :baz
    end
  end

  context "stub that yields" do
    context "when yields called without any arguments" do
      it "yields only once" do
        called_from_block = mock!.foo.once.subject
        block_caller = stub!.bar.yields.subject
        block_caller.bar { called_from_block.foo }
      end
    end

    context "when yields called with an argument" do
      it "yields only once" do
        called_from_block = mock!.foo(1).once.subject
        block_caller = stub!.bar.yields(1).subject
        block_caller.bar { |argument| called_from_block.foo(argument) }
      end
    end

    context "when yields calls are chained" do
      it "yields several times" do
        called_from_block = mock!.foo(1).once.then.foo(2).once.subject
        block_caller = stub!.bar.yields(1).yields(2).subject
        block_caller.bar { |argument| called_from_block.foo(argument) }
      end
    end
  end
end
