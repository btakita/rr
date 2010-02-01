require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe "proxy" do
  attr_reader :subject
  before(:each) do
    @subject = Object.new
    extend RR::Adapters::RRMethods
  end

  after(:each) do
    RR.reset
  end

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
