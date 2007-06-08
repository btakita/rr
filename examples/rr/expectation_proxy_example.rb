dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR

describe ExpectationProxy, :shared => true do
  before(:each) do
    @space = RR::Space.new
  end
end

describe ExpectationProxy, ".new with nothing passed in" do
  it_should_behave_like "RR::ExpectationProxy"

  it "initializes proxy with Object" do
    proxy = RR::ExpectationProxy.new(@space)
    class << proxy
      attr_reader :subject
    end
    proxy.subject.class.should == Object
  end
end

describe ExpectationProxy, ".new with one thing passed in" do
  it_should_behave_like "RR::ExpectationProxy"

  it "initializes proxy with passed in object" do
    subject = Object.new
    proxy = RR::ExpectationProxy.new(@space, subject)
    class << proxy
      attr_reader :subject
    end
    proxy.subject.should === subject
  end
end

describe ExpectationProxy, ".new with two things passed in" do
  it_should_behave_like "RR::ExpectationProxy"
  
  it "raises Argument error" do
    proc {RR::ExpectationProxy.new(@space, nil, nil)}.should raise_error(ArgumentError, "wrong number of arguments (2 for 1)")
  end
end

describe ExpectationProxy, "#method_missing" do
  it_should_behave_like "RR::ExpectationProxy"
  
  before do
    @subject = Object.new
    @proxy = RR::ExpectationProxy.new(@space, @subject)
  end

  it "sets expectations on the subject" do
    @proxy.foobar(1, 2) {:baz}

    @subject.foobar(1, 2).should == :baz
    proc {@subject.foobar(1)}.should raise_error(RR::Expectations::ArgumentEqualityExpectationError)
  end
end

end