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
  include RR::Adapters::RRMethods

  after(:each) do
    RR.reset
  end

  subject { Object.new }

  it "creates a stub DoubleInjection Double" do
    stub(subject).foobar {:baz}
    expect(subject.foobar("any", "thing")).to eq :baz
  end

  it "stubs via inline call" do
    stub(subject).to_s {"a value"}
    expect(subject.to_s).to eq "a value"
  end

  describe ".once.ordered" do
    it "returns the values in the ordered called" do
      stub(subject).to_s {"value 1"}.once.ordered
      stub(subject).to_s {"value 2"}.once.ordered

      expect(subject.to_s).to eq "value 1"
      expect(subject.to_s).to eq "value 2"
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
      expect(proxy.methods).to match_array(proxy_target.methods)

      stub(proxy).foobar {:new_foobar}
      expect(proxy.foobar).to eq :new_foobar
    end
  end

  it "stubs via block with argument" do
    stub subject do |d|
      d.to_s {"a value"}
      d.to_sym {:crazy}
    end
    expect(subject.to_s).to eq "a value"
    expect(subject.to_sym).to eq :crazy
  end

  it "stubs via block without argument" do
    stub subject do
      to_s {"a value"}
      to_sym {:crazy}
    end
    expect(subject.to_s).to eq "a value"
    expect(subject.to_sym).to eq :crazy
  end

  it "stubs instance_of" do
    stub.instance_of(StubSpecFixture) do |o|
      o.to_s {"High Level Spec"}
    end
    expect(StubSpecFixture.new.to_s).to eq "High Level Spec"
  end

  it "stubs methods without letters" do
    stub(subject).__send__(:==) {:equality}
    expect((subject == 55)).to eq :equality
  end

  it "stubs methods invoked in #initialize while passing along the #initialize arg" do
    method_run_in_initialize_stubbed = false
    stub.instance_of(StubSpecFixture) do |o|
      o.method_run_in_initialize {method_run_in_initialize_stubbed = true}
    end
    StubSpecFixture.new
    expect(method_run_in_initialize_stubbed).to be_true
  end

  it "passed the arguments and block passed to #initialize" do
    block_called = false
    stub.instance_of(StubSpecFixture) do |o|
      o.method_run_in_initialize
    end
    instance = StubSpecFixture.new(1, 2) {block_called = true}
    expect(instance.initialize_arguments).to eq [1, 2]
    expect(block_called).to be_true
  end

  context "mock then stub" do
    it "stubs any calls not matching the mock" do
      mock(subject).foobar(3) {:baz3}
      stub(subject).foobar {:baz}
      expect(subject.foobar(3)).to eq :baz3
      expect(subject.foobar(4)).to eq :baz
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

  # bug #44
  describe 'when wrapped in an array that is then flattened' do
    context 'when the method being mocked is not defined' do
      it "does not raise an error" do
        stub(subject).foo
        expect([subject].flatten).to eq [subject]
      end

      it "honors a #to_ary that already exists" do
        subject.instance_eval do
          def to_ary; []; end
        end
        stub(subject).foo
        expect([subject].flatten).to eq []
      end
    end

    context 'when the method being mocked is defined' do
      before do
        subject.instance_eval do
          def foo; end
        end
      end

      it "does not raise an error" do
        stub(subject).foo
        expect([subject].flatten).to eq [subject]
      end

      it "honors a #to_ary that already exists" do
        eigen(subject).class_eval do
          def to_ary; []; end
        end
        stub(subject).foo
        expect([subject].flatten).to eq []
      end
    end
  end
end
