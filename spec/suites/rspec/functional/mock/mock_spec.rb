require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe "mock" do
  include RR::Adapters::RRMethods

  after(:each) do
    RR.reset
  end

  subject { Object.new }

  it "creates a mock DoubleInjection Double" do
    mock(subject).foobar(1, 2) {:baz}
    expect(subject.foobar(1, 2)).to eq :baz
  end

  it "mocks via inline call" do
    mock(subject).to_s {"a value"}
    expect(subject.to_s).to eq "a value"
    expect { subject.to_s }.to raise_error(RR::Errors::TimesCalledError)
  end

  describe ".once.ordered" do
    it "returns the values in the ordered called" do
      mock(subject).to_s {"value 1"}.ordered
      mock(subject).to_s {"value 2"}.twice
      expect(subject.to_s).to eq "value 1"
      expect(subject.to_s).to eq "value 2"
      expect(subject.to_s).to eq "value 2"
      expect { subject.to_s }.to raise_error(RR::Errors::TimesCalledError)
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

      mock(proxy).foobar {:new_foobar}
      expect(proxy.foobar).to eq :new_foobar
    end
  end

  it 'allows terse chaining' do
    mock(subject).first(1) {mock(Object.new).second(2) {mock(Object.new).third(3) {4}}}
    expect(subject.first(1).second(2).third(3)).to eq 4

    mock(subject).first(1) {mock!.second(2) {mock!.third(3) {4}}}
    expect(subject.first(1).second(2).third(3)).to eq 4

    mock(subject).first(1) {mock!.second(2).mock!.third(3) {4}}
    expect(subject.first(1).second(2).third(3)).to eq 4

    mock(subject).first(1) {mock!.second(2).mock! {third(3) {4}}}
    expect(subject.first(1).second(2).third(3)).to eq 4

    mock(subject).first(1).mock!.second(2).mock!.third(3) {4}
    expect(subject.first(1).second(2).third(3)).to eq 4
  end

  it 'allows chaining with proxy' do
    find_return_value = Object.new
    def find_return_value.child
      :the_child
    end
    (class << subject; self; end).class_eval do
      define_method(:find) do |id|
        id == '1' ? find_return_value : raise(ArgumentError)
      end
    end

    mock.proxy(subject).find('1').mock.proxy!.child
    expect(subject.find('1').child).to eq :the_child
  end

  it 'allows branched chaining' do
    mock(subject).first do
      mock! do |expect|
        expect.branch1 {mock!.branch11 {11}}
        expect.branch2 {mock!.branch22 {22}}
      end
    end
    o = subject.first
    expect(o.branch1.branch11).to eq 11
    expect(o.branch2.branch22).to eq 22
  end

  it 'allows chained ordering' do
    mock(subject).to_s {"value 1"}.then.to_s {"value 2"}.twice.then.to_s {"value 3"}.once
    expect(subject.to_s).to eq "value 1"
    expect(subject.to_s).to eq "value 2"
    expect(subject.to_s).to eq "value 2"
    expect(subject.to_s).to eq "value 3"
    expect { subject.to_s }.to raise_error(RR::Errors::TimesCalledError)
  end

  it "mocks via block with argument" do
    mock subject do |c|
      c.to_s {"a value"}
      c.to_sym {:crazy}
    end
    expect(subject.to_s).to eq "a value"
    expect(subject.to_sym).to eq :crazy
  end

  it "mocks via block without argument" do
    mock subject do
      to_s {"a value"}
      to_sym {:crazy}
    end
    expect(subject.to_s).to eq "a value"
    expect(subject.to_sym).to eq :crazy
  end

  it "has wildcard matchers" do
    mock(subject).foobar(
      is_a(String),
      anything,
      numeric,
      boolean,
      duck_type(:to_s),
      /abc/
    ) {"value 1"}.twice
    expect(subject.foobar(
      'hello',
      Object.new,
      99,
      false,
      "My String",
      "Tabcola"
    )).to eq("value 1")
    expect {
      subject.foobar(:failure)
    }.to raise_error(RR::Errors::DoubleNotFoundError)
  end

  it "mocks methods without letters" do
    mock(subject, :==).with(55)

    subject == 55
    expect {
      subject == 99
    }.to raise_error(RR::Errors::DoubleNotFoundError)
  end

  it "expects a method call to a mock via another mock's block yield only once" do
    cage = Object.new
    cat = Object.new
    mock(cat).miau    # should be expected to be called only once
    mock(cage).find_cat.yields(cat)
    mock(cage).cats
    cage.find_cat { |c| c.miau }
    cage.cats
  end

  describe "on class method" do
    class SampleClass1
      def self.hello; "hello!"; end
    end

    class SampleClass2 < SampleClass1; end

    it "can mock" do
      mock(SampleClass1).hello { "hola!" }

      expect(SampleClass1.hello).to eq "hola!"
    end

    it "does not override subclasses" do
      mock(SampleClass1).hello { "hi!" }

      expect(SampleClass2.hello).to eq "hello!"
    end

    it "should not get affected from a previous example" do
      expect(SampleClass2.hello).to eq "hello!"
    end

  end

  # bug #44
  describe 'when wrapped in an array that is then flattened' do
    context 'when the method being mocked is not defined' do
      it "does not raise an error" do
        mock(subject).foo
        expect([subject].flatten).to eq [subject]
      end

      it "honors a #to_ary that already exists" do
        subject.instance_eval do
          def to_ary; []; end
        end
        mock(subject).foo
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
        mock(subject).foo
        expect([subject].flatten).to eq [subject]
      end

      it "honors a #to_ary that already exists" do
        eigen(subject).class_eval do
          def to_ary; []; end
        end
        mock(subject).foo
        expect([subject].flatten).to eq []
      end
    end
  end
end
