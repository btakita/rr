require "examples/example_helper"

module RR
describe StubProbeCreator, :shared => true do
  before(:each) do
    @space = Space.new
    @subject = Object.new
  end

  it "initializes creator with passed in object" do
    @creator.subject.should === @subject
  end
end

describe StubProbeCreator, "#create" do
  it_should_behave_like "RR::StubProbeCreator"
  
  before do
    @subject = Object.new
    @creator = StubProbeCreator.new(@space, @subject)
  end
  
  it "sets up a scenario with passed in arguments" do
    def @subject.foobar(*args); :baz; end
    @creator.create(:foobar, 1, 2)
    proc do
      @subject.foobar
    end.should raise_error(Errors::ScenarioNotFoundError)
  end

  it "sets expectations on the subject while calling the original method" do
    def @subject.foobar(*args); :baz; end
    @creator.create(:foobar, 1, 2) {:new_value}
    10.times do
      @subject.foobar(1, 2).should == :new_value
    end
  end

  it "sets after_call on the scenario when passed a block" do
    real_value = Object.new
    (class << @subject; self; end).class_eval do
      define_method(:foobar) {real_value}
    end
    @creator.create(:foobar, 1, 2) do |value|
      mock(value).a_method {99}
      value
    end

    return_value = @subject.foobar(1, 2)
    return_value.should === return_value
    return_value.a_method.should == 99
  end
end

end