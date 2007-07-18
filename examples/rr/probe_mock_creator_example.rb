require "examples/example_helper"

module RR
describe ProbeMockCreator, :shared => true do
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

describe ProbeMockCreator, ".new without block" do
  it_should_behave_like "RR::ProbeMockCreator"

  before do
    @creator = ProbeMockCreator.new(@space, @subject)
  end

  it "clears out all methods from creator" do
    creator_subclass = Class.new(ProbeMockCreator) do
      def i_should_be_a_scenario
      end
    end
    creator_subclass.instance_methods.should include('i_should_be_a_scenario')

    creator = creator_subclass.new(@space, @subject)
    creator.i_should_be_a_scenario.should be_instance_of(Scenario)
  end
end

describe ProbeMockCreator, ".new with block" do
  it_should_behave_like "RR::ProbeMockCreator"

  before do
    def @subject.foobar(*args)
      :original_foobar
    end
    @creator = ProbeMockCreator.new(@space, @subject) do |c|
      c.foobar(1, 2)
      c.foobar(1)
      c.foobar.with_any_args
    end
  end

  it "creates doubles" do
    @subject.foobar(1, 2).should == :original_foobar
    @subject.foobar(1).should == :original_foobar
    @subject.foobar(:something).should == :original_foobar
    proc {@subject.foobar(:nasty)}.should raise_error
  end

  it "clears out all methods from creator" do
    creator_subclass = Class.new(ProbeMockCreator) do
      def i_should_be_a_scenario
      end
    end
    creator_subclass.instance_methods.should include('i_should_be_a_scenario')

    creator_subclass.new(@space, @subject) do |m|
      m.i_should_be_a_scenario.should be_instance_of(Scenario)
    end
  end
end

describe ProbeMockCreator, ".new where method takes a block" do
  it_should_behave_like "RR::ProbeMockCreator"

  before do
    def @subject.foobar(*args, &block)
      yield(*args)
    end
    @creator = ProbeMockCreator.new(@space, @subject)
  end

  it "calls the block" do
    @creator.foobar(1, 2)
    @subject.foobar(1, 2) {|arg1, arg2| [arg2, arg1]}.should == [2, 1]
  end
end


describe ProbeMockCreator, "#method_missing" do
  it_should_behave_like "RR::ProbeMockCreator"
  
  before do
    @subject = Object.new
    @creator = ProbeMockCreator.new(@space, @subject)
  end

  it "sets expectations on the subject while calling the original method" do
    def @subject.foobar(*args); :baz; end
    @creator.foobar(1, 2).twice
    @subject.foobar(1, 2).should == :baz
    @subject.foobar(1, 2).should == :baz
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
  end

  it "sets after_call on the scenario when passed a block" do
    real_value = Object.new
    (class << @subject; self; end).class_eval do
      define_method(:foobar) {real_value}
    end
    @creator.foobar(1, 2) do |value|
      mock(value).a_method {99}
      value
    end

    return_value = @subject.foobar(1, 2)
    return_value.should === return_value
    return_value.a_method.should == 99
  end
end

end