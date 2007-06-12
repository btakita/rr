dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR

describe StubCreationProxy, :shared => true do
  before(:each) do
    @space = RR::Space.new
  end
end

describe StubCreationProxy, ".new with nothing passed in" do
  it_should_behave_like "RR::StubCreationProxy"

  it "initializes proxy with Object" do
    proxy = RR::StubCreationProxy.new(@space)
    class << proxy
      attr_reader :subject
    end
    proxy.subject.class.should == Object
  end
end

describe StubCreationProxy, ".new with one thing passed in" do
  it_should_behave_like "RR::StubCreationProxy"

  it "initializes proxy with passed in object" do
    subject = Object.new
    proxy = RR::StubCreationProxy.new(@space, subject)
    class << proxy
      attr_reader :subject
    end
    proxy.subject.should === subject
  end
end

describe StubCreationProxy, ".new with two things passed in" do
  it_should_behave_like "RR::StubCreationProxy"
  
  it "raises Argument error" do
    proc {RR::StubCreationProxy.new(@space, nil, nil)}.should raise_error(ArgumentError, "wrong number of arguments (2 for 1)")
  end
end

describe StubCreationProxy, "#method_missing" do
  it_should_behave_like "RR::StubCreationProxy"
  
  before do
    @subject = Object.new
    @proxy = RR::StubCreationProxy.new(@space, @subject)
  end

  it "stubs the subject without any args" do
    @proxy.foobar {:baz}
    @subject.foobar.should == :baz
  end

  it "stubs the subject mapping passed in args with the output"
  it "stubs the subject defaulting the value to the one passed in without arguments"
end

end