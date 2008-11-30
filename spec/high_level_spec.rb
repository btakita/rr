require File.expand_path("#{File.dirname(__FILE__)}/spec_helper")

class HighLevelSpec
end

describe "RR" do
  attr_reader :subject
  before(:each) do
    @subject = Object.new
    extend RR::Adapters::RRMethods
  end

  after(:each) do
    RR.reset
  end

  describe "mock" do
    it "mocks via inline call" do
      mock(subject).to_s {"a value"}
      subject.to_s.should == "a value"
      lambda {subject.to_s}.should raise_error(RR::Errors::TimesCalledError)
    end

    it "allows ordering" do
      mock(subject).to_s {"value 1"}.ordered
      mock(subject).to_s {"value 2"}.twice
      subject.to_s.should == "value 1"
      subject.to_s.should == "value 2"
      subject.to_s.should == "value 2"
      lambda {subject.to_s}.should raise_error(RR::Errors::TimesCalledError)
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
      mock(subject) == 55

      subject == 55
      lambda do
        subject == 99
      end.should raise_error(RR::Errors::DoubleNotFoundError)
    end
  end

  describe "proxy" do
    it "proxies via inline call" do
      expected_to_s_value = subject.to_s
      mock.proxy(subject).to_s
      subject.to_s.should == expected_to_s_value
      lambda {subject.to_s}.should raise_error
    end

    it "proxy allows ordering" do
      def subject.to_s(arg)
        "Original to_s with arg #{arg}"
      end
      mock.proxy(subject).to_s(:foo).ordered
      mock.proxy(subject).to_s(:bar).twice.ordered

      subject.to_s(:foo).should == "Original to_s with arg foo"
      subject.to_s(:bar).should == "Original to_s with arg bar"
      subject.to_s(:bar).should == "Original to_s with arg bar"
      lambda {subject.to_s(:bar)}.should raise_error(RR::Errors::TimesCalledError)
    end

    it "proxy allows ordering" do
      def subject.to_s(arg)
        "Original to_s with arg #{arg}"
      end
      mock.proxy(subject).to_s(:foo).ordered
      mock.proxy(subject).to_s(:bar).twice.ordered

      subject.to_s(:foo).should == "Original to_s with arg foo"
      subject.to_s(:bar).should == "Original to_s with arg bar"
      subject.to_s(:bar).should == "Original to_s with arg bar"
      lambda {subject.to_s(:bar)}.should raise_error(RR::Errors::TimesCalledError)
    end

    it "proxies via block with argument" do
      def subject.foobar_1(*args)
        :original_value_1
      end

      def subject.foobar_2
        :original_value_2
      end

      mock.proxy subject do |c|
        c.foobar_1(1)
        c.foobar_2
      end
      subject.foobar_1(1).should == :original_value_1
      lambda {subject.foobar_1(:blah)}.should raise_error

      subject.foobar_2.should == :original_value_2
      lambda {subject.foobar_2(:blah)}.should raise_error
    end

    it "proxies via block without argument" do
      def subject.foobar_1(*args)
        :original_value_1
      end

      def subject.foobar_2
        :original_value_2
      end

      mock.proxy subject do
        foobar_1(1)
        foobar_2
      end
      subject.foobar_1(1).should == :original_value_1
      lambda {subject.foobar_1(:blah)}.should raise_error

      subject.foobar_2.should == :original_value_2
      lambda {subject.foobar_2(:blah)}.should raise_error
    end
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
      stub.instance_of(HighLevelSpec) do |o|
        o.to_s {"High Level Spec"}
      end
      HighLevelSpec.new.to_s.should == "High Level Spec"
    end

    it "stubs methods without letters" do
      stub(subject).__send__(:==) {:equality}
      (subject == 55).should == :equality
    end
  end

  describe "RR recorded_calls" do
    it "should verify method calls after the fact" do
      stub(subject).pig_rabbit
      subject.pig_rabbit("bacon", "bunny meat")
      #subject.should have_received.pig_rabitt("bacon", "bunny meat")
      received(subject).pig_rabbit("bacon", "bunny meat").call
    end
    
    it "should verify method calls after the fact" do
      stub(subject).pig_rabbit
      lambda do
        received(subject).pig_rabbit("bacon", "bunny meat").call
      end.should raise_error(RR::Errors::SpyVerificationErrors::SpyVerificationError)
    end
  end
  
  class StrongTestObject
    def method_with_no_arguments
    end

    def method_with_one_argument(string)
    end

    def method_with_two_arguments(string, integer)
    end

    def method_with_three_arguments_including_varargs(string, integer, *args)
    end

    def method_with_varargs(*args)
    end
  end

  describe "strong" do
    context "when the method does not exist" do
      it "raises an exception" do
        lambda do
          strong.stub(StrongTestObject.new).something
        end.should raise_error(RR::Errors::SubjectDoesNotImplementMethodError)
      end
    end

    context "when the method exists with no arguments" do
      it "does not raise an exception" do
        strong.stub(StrongTestObject.new).method_with_no_arguments
      end
    end

    context "when the method has a different arity" do
      it "raises an exception" do
        lambda do
          strong.stub(StrongTestObject.new).method_with_one_argument
        end.should raise_error(RR::Errors::SubjectHasDifferentArityError)
      end
    end

    context "when the method has accepts a variable number of arguments" do
      it "does not raise an exception" do
        strong.stub(StrongTestObject.new).method_with_varargs
      end
    end

    context "when the method does not provide the required parameters before varargs" do
      it "raises an exception" do
        lambda do
          strong.stub(StrongTestObject.new).method_with_three_arguments_including_varargs
        end.should raise_error(RR::Errors::SubjectHasDifferentArityError)
      end
    end

    context "when the minimum number of parameters are provided" do
      it "does not raise an exception" do
        strong.stub(StrongTestObject.new).method_with_three_arguments_including_varargs("one", 2)
      end
    end

    context "when using instance_of and the method does not exist" do
      it "raises an exception" do
        lambda do
          strong.stub.instance_of(StrongTestObject).something
          StrongTestObject.new
        end.should raise_error(RR::Errors::SubjectDoesNotImplementMethodError)
      end
    end

    context "when using instance_of and the method does exist" do
      it "does not raise an exception" do
        strong.stub.instance_of(StrongTestObject).method_with_no_arguments
      end
    end
  end

  describe "spy" do
    it "should record all method invocations" do
      subject = Object.new
      def subject.something
      end

      def subject.something_else
      end

      spy(subject)

      subject.something
      subject.something_else
      subject.to_s

      received(subject).something.call
      received(subject).something_else.call
      received(subject).to_s.call
    end
  end
end
