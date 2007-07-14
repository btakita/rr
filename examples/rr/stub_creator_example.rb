require "examples/example_helper"

module RR
describe StubCreator, :shared => true do
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

describe StubCreator, ".new without block" do
  it_should_behave_like "RR::StubCreator"

  before do
    @creator = StubCreator.new(@space, @subject)
  end

  it "clears out all methods from creator" do
    creator_subclass = Class.new(StubCreator) do
      def i_should_be_a_scenario
      end
    end
    creator_subclass.instance_methods.should include('i_should_be_a_scenario')

    creator = creator_subclass.new(@space, @subject)
    creator.i_should_be_a_scenario.should be_instance_of(Scenario)
  end
end

describe StubCreator, ".new with block" do
  it_should_behave_like "RR::StubCreator"

  before do
    @creator = StubCreator.new(@space, @subject) do |c|
      c.foobar(1, 2) {:one_two}
      c.foobar(1) {:one}
      c.foobar.with_any_args {:default}
      c.baz() {:baz_result}
    end
  end

  it "creates doubles" do
    @subject.foobar(1, 2).should == :one_two
    @subject.foobar(1, 2).should == :one_two
    @subject.foobar(1).should == :one
    @subject.foobar(1).should == :one
    @subject.foobar(:something).should == :default
    @subject.foobar(:something).should == :default
    @subject.baz.should == :baz_result
    @subject.baz.should == :baz_result
  end

  it "clears out all methods from creator" do
    creator_subclass = Class.new(StubCreator) do
      def i_should_be_a_scenario
      end
    end
    creator_subclass.instance_methods.should include('i_should_be_a_scenario')

    creator_subclass.new(@space, @subject) do |m|
      m.i_should_be_a_scenario.should be_instance_of(Scenario)
    end
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

  it "stubs the subject mapping passed in args with the output" do
    @creator.foobar(1, 2) {:one_two}
    @creator.foobar(1) {:one}
    @creator.foobar() {:nothing}
    @subject.foobar.should == :nothing
    @subject.foobar(1).should == :one
    @subject.foobar(1, 2).should == :one_two
  end
end

end