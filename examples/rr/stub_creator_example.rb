dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
describe StubCreator, :shared => true do
  before(:each) do
    @space = Space.new
  end
end

describe StubCreator, ".new with nothing passed in" do
  it_should_behave_like "RR::StubCreator"

  it "initializes creator with Object" do
    creator = StubCreator.new(@space)
    class << creator
      attr_reader :subject
    end
    creator.subject.class.should == Object
  end
end

describe StubCreator, ".new with one thing passed in" do
  it_should_behave_like "RR::StubCreator"

  it "initializes creator with passed in object" do
    subject = Object.new
    creator = StubCreator.new(@space, subject)
    class << creator
      attr_reader :subject
    end
    creator.subject.should === subject
  end
end

describe StubCreator, ".new with two things passed in" do
  it_should_behave_like "RR::StubCreator"
  
  it "raises Argument error" do
    proc {StubCreator.new(@space, nil, nil)}.should raise_error(ArgumentError, "wrong number of arguments (2 for 1)")
  end
end

describe StubCreator, "#method_missing" do
  it_should_behave_like "RR::StubCreator"
  
  before do
    @subject = Object.new
    @creator = StubCreator.new(@space, @subject)
  end

  it "stubs the subject without any args" do
    @creator.foobar {:baz}
    @subject.foobar.should == :baz
  end

  it "stubs the subject mapping passed in args with the output"
  it "stubs the subject defaulting the value to the one passed in without arguments"
end

end