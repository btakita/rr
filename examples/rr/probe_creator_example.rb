dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
describe ProbeCreator, :shared => true do
  before(:each) do
    @space = Space.new
  end
end

describe ProbeCreator, ".new with nothing passed in" do
  it_should_behave_like "RR::ProbeCreator"

  it "initializes creator with Object" do
    creator = ProbeCreator.new(@space)
    class << creator
      attr_reader :subject
    end
    creator.subject.class.should == Object
  end
end

describe ProbeCreator, ".new with one thing passed in" do
  it_should_behave_like "RR::ProbeCreator"

  it "initializes creator with passed in object" do
    subject = Object.new
    creator = ProbeCreator.new(@space, subject)
    class << creator
      attr_reader :subject
    end
    creator.subject.should === subject
  end
end

describe ProbeCreator, ".new with two things passed in" do
  it_should_behave_like "RR::ProbeCreator"
  
  it "raises Argument error" do
    proc {ProbeCreator.new(@space, nil, nil)}.should raise_error(ArgumentError, "wrong number of arguments (2 for 1)")
  end
end

describe ProbeCreator, "#method_missing" do
  it_should_behave_like "RR::ProbeCreator"
  
  before do
    @subject = Object.new
    @creator = ProbeCreator.new(@space, @subject)
  end

  it "sets expectations on the subject while calling the original method" do
    def @subject.foobar(*args); :baz; end
    @creator.foobar(1, 2).twice
    @subject.foobar(1, 2).should == :baz
    @subject.foobar(1, 2).should == :baz
    proc {@subject.foobar(1, 2)}.should raise_error(Expectations::TimesCalledExpectationError)
#    proc {@subject.foobar(1)}.should raise_error(Expectations::ArgumentEqualityExpectationError)
  end
end

end