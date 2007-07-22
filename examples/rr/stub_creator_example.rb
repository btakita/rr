require "examples/example_helper"

module RR
describe StubCreator, :shared => true do
  before(:each) do
    @space = Space.new
    @subject = Object.new
  end

  it "initializes creator with passed in object" do
    @creator.subject.should === @subject
  end
end

describe StubCreator, "#create" do
  it_should_behave_like "RR::StubCreator"
  
  before do
    @subject = Object.new
    @creator = StubCreator.new(@space, @subject)
  end

  it "stubs the subject without any args" do
    @creator.create(:foobar) {:baz}
    @subject.foobar.should == :baz
  end

  it "stubs the subject mapping passed in args with the output" do
    @creator.create(:foobar, 1, 2) {:one_two}
    @creator.create(:foobar, 1) {:one}
    @creator.create(:foobar) {:nothing}
    @subject.foobar.should == :nothing
    @subject.foobar(1).should == :one
    @subject.foobar(1, 2).should == :one_two
  end
end

end