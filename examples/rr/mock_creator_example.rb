dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
describe MockCreator, :shared => true do
  before(:each) do
    @space = Space.new
  end
end

describe MockCreator, ".new with one thing passed in" do
  it_should_behave_like "RR::MockCreator"

  it "initializes creator with passed in object" do
    subject = Object.new
    creator = MockCreator.new(@space, subject)
    class << creator
      attr_reader :subject
    end
    creator.subject.should === subject
  end
end

describe MockCreator, "#method_missing" do
  it_should_behave_like "RR::MockCreator"
  
  before do
    @subject = Object.new
    @creator = MockCreator.new(@space, @subject)
  end

  it "sets expectations on the subject" do
    @creator.foobar(1, 2) {:baz}.twice

    @subject.foobar(1, 2).should == :baz
    @subject.foobar(1, 2).should == :baz
    proc {@subject.foobar(1, 2)}.should raise_error(Expectations::TimesCalledExpectationError)
#    proc {@subject.foobar(1)}.should raise_error(Expectations::ArgumentEqualityExpectationError)
  end
end

end