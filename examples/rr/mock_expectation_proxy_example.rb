dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR

describe MockExpectationProxy, :shared => true do
  before(:each) do
    @space = RR::Space.new
  end
end

describe MockExpectationProxy, ".new with nothing passed in" do
  it_should_behave_like "RR::MockExpectationProxy"

  it "initializes proxy with Object" do
    proxy = RR::MockExpectationProxy.new(@space)
    class << proxy
      attr_reader :subject
    end
    proxy.subject.class.should == Object
  end
end

describe MockExpectationProxy, ".new with one thing passed in" do
  it_should_behave_like "RR::MockExpectationProxy"

  it "initializes proxy with passed in object" do
    subject = Object.new
    proxy = RR::MockExpectationProxy.new(@space, subject)
    class << proxy
      attr_reader :subject
    end
    proxy.subject.should === subject
  end
end

describe MockExpectationProxy, ".new with two things passed in" do
  it_should_behave_like "RR::MockExpectationProxy"
  
  it "raises Argument error" do
    proc {RR::MockExpectationProxy.new(@space, nil, nil)}.should raise_error(ArgumentError, "wrong number of arguments (2 for 1)")
  end
end

describe MockExpectationProxy, "#method_missing" do
  it_should_behave_like "RR::MockExpectationProxy"
  
  before do
    @subject = Object.new
    @proxy = RR::MockExpectationProxy.new(@space, @subject)
  end

  it "sets expectations on the subject" do
    @proxy.foobar(1, 2) {:baz}.twice

    @subject.foobar(1, 2).should == :baz
    @subject.foobar(1, 2).should == :baz
    proc {@subject.foobar(1, 2)}.should raise_error(RR::Expectations::TimesCalledExpectationError)
#    proc {@subject.foobar(1)}.should raise_error(RR::Expectations::ArgumentEqualityExpectationError)
  end
end

end