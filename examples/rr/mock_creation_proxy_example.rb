dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR

describe MockCreationProxy, :shared => true do
  before(:each) do
    @space = RR::Space.new
  end
end

describe MockCreationProxy, ".new with nothing passed in" do
  it_should_behave_like "RR::MockCreationProxy"

  it "initializes proxy with Object" do
    proxy = RR::MockCreationProxy.new(@space)
    class << proxy
      attr_reader :subject
    end
    proxy.subject.class.should == Object
  end
end

describe MockCreationProxy, ".new with one thing passed in" do
  it_should_behave_like "RR::MockCreationProxy"

  it "initializes proxy with passed in object" do
    subject = Object.new
    proxy = RR::MockCreationProxy.new(@space, subject)
    class << proxy
      attr_reader :subject
    end
    proxy.subject.should === subject
  end
end

describe MockCreationProxy, ".new with two things passed in" do
  it_should_behave_like "RR::MockCreationProxy"
  
  it "raises Argument error" do
    proc {RR::MockCreationProxy.new(@space, nil, nil)}.should raise_error(ArgumentError, "wrong number of arguments (2 for 1)")
  end
end

describe MockCreationProxy, "#method_missing" do
  it_should_behave_like "RR::MockCreationProxy"
  
  before do
    @subject = Object.new
    @proxy = RR::MockCreationProxy.new(@space, @subject)
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