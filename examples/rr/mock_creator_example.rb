require "examples/example_helper"

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

  it "clears out all methods from creator" do
    creator_subclass = Class.new(MockCreator) do
      def i_should_be_a_scenario
      end
    end
    creator_subclass.instance_methods.should include('i_should_be_a_scenario')

    creator = creator_subclass.new(@space, @subject)
    creator.i_should_be_a_scenario.should be_instance_of(Scenario)
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

  it "clears out all methods from creator" do
    creator_subclass = Class.new(MockCreator) do
      def i_should_be_a_scenario
      end
    end
    creator_subclass.instance_methods.should include('i_should_be_a_scenario')

    creator_subclass.new(@space, @subject) do |m|
      m.i_should_be_a_scenario.should be_instance_of(Scenario)
    end
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