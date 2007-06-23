dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
describe MockCreator, :shared => true do
  before(:each) do
    @space = Space.new
    @subject = Object.new
  end

  it "initializes creator with passed in object" do
    class << @creator
      attr_reader :subject
    end
    @creator.subject.should === @subject
  end
end

describe MockCreator, ".new without block" do
  it_should_behave_like "RR::MockCreator"

  before do
    @creator = MockCreator.new(@space, @subject)
  end
end

describe MockCreator, ".new with block" do
  it_should_behave_like "RR::MockCreator"

  before do
    @creator = MockCreator.new(@space, @subject) do |c|
      c.foobar(1, 2) {:one_two}
      c.foobar(1) {:one}
      c.foobar.with_any_args {:default}
      c.baz() {:baz_result}
    end
  end

  it "creates doubles" do
    @subject.foobar(1, 2).should == :one_two
    @subject.foobar(1).should == :one
    @subject.foobar(:something).should == :default
    @subject.baz.should == :baz_result
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