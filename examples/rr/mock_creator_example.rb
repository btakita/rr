require "examples/example_helper"

module RR
describe MockCreator, :shared => true do
  before(:each) do
    @space = Space.new
    @subject = Object.new
  end

  it "initializes creator with passed in object" do
    @creator.subject.should === @subject
  end
end

describe MockCreator, "#create" do
  it_should_behave_like "RR::MockCreator"
  
  before do
    @subject = Object.new
    @creator = MockCreator.new(@space, @subject)
  end

  it "sets expectations on the subject" do
    @creator.create(:foobar, 1, 2) {:baz}.twice

    @subject.foobar(1, 2).should == :baz
    @subject.foobar(1, 2).should == :baz
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
  end
end

end