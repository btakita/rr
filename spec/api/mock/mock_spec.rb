require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe "mock" do
  attr_reader :subject
  before(:each) do
    @subject = Object.new
    extend RR::Adapters::RRMethods
  end

  after(:each) do
    RR.reset
  end

  it "mocks via inline call" do
    mock(subject).to_s {"a value"}
    subject.to_s.should == "a value"
    lambda {subject.to_s}.should raise_error(RR::Errors::TimesCalledError)
  end

  describe ".once.ordered" do
    it "returns the values in the ordered called" do
      mock(subject).to_s {"value 1"}.ordered
      mock(subject).to_s {"value 2"}.twice
      subject.to_s.should == "value 1"
      subject.to_s.should == "value 2"
      subject.to_s.should == "value 2"
      lambda {subject.to_s}.should raise_error(RR::Errors::TimesCalledError)
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

      mock(proxy).foobar {:new_foobar}
      proxy.foobar.should == :new_foobar
    end
  end

  it 'allows terse chaining' do
    mock(subject).first(1) {mock(Object.new).second(2) {mock(Object.new).third(3) {4}}}
    subject.first(1).second(2).third(3).should == 4

    mock(subject).first(1) {mock!.second(2) {mock!.third(3) {4}}}
    subject.first(1).second(2).third(3).should == 4

    mock(subject).first(1) {mock!.second(2).mock!.third(3) {4}}
    subject.first(1).second(2).third(3).should == 4

    mock(subject).first(1) {mock!.second(2).mock! {third(3) {4}}}
    subject.first(1).second(2).third(3).should == 4

    mock(subject).first(1).mock!.second(2).mock!.third(3) {4}
    subject.first(1).second(2).third(3).should == 4
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
    subject.find('1').child.should == :the_child
  end

  it 'allows branched chaining' do
    mock(subject).first do
      mock! do |expect|
        expect.branch1 {mock!.branch11 {11}}
        expect.branch2 {mock!.branch22 {22}}
      end
    end
    o = subject.first
    o.branch1.branch11.should == 11
    o.branch2.branch22.should == 22
  end

  it 'allows chained ordering' do
    mock(subject).to_s {"value 1"}.then.to_s {"value 2"}.twice.then.to_s {"value 3"}.once
    subject.to_s.should == "value 1"
    subject.to_s.should == "value 2"
    subject.to_s.should == "value 2"
    subject.to_s.should == "value 3"
    lambda {subject.to_s}.should raise_error(RR::Errors::TimesCalledError)
  end

  it "mocks via block with argument" do
    mock subject do |c|
      c.to_s {"a value"}
      c.to_sym {:crazy}
    end
    subject.to_s.should == "a value"
    subject.to_sym.should == :crazy
  end

  it "mocks via block without argument" do
    mock subject do
      to_s {"a value"}
      to_sym {:crazy}
    end
    subject.to_s.should == "a value"
    subject.to_sym.should == :crazy
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
    subject.foobar(
      'hello',
      Object.new,
      99,
      false,
      "My String",
      "Tabcola"
    ).should == "value 1"
    lambda do
      subject.foobar(:failure)
    end.should raise_error( RR::Errors::DoubleNotFoundError )
  end

  it "mocks methods without letters" do
    mock(subject, :==).with(55)

    subject == 55
    lambda do
      subject == 99
    end.should raise_error(RR::Errors::DoubleNotFoundError)
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

      SampleClass1.hello.should == "hola!"
    end

    it "does not override subclasses" do
      mock(SampleClass1).hello { "hi!" }

      SampleClass2.hello.should == "hello!"
    end

    it "should not get affected from a previous example" do
      SampleClass2.hello.should == "hello!"
    end

  end
end
