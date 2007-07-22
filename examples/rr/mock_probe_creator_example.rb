require "examples/example_helper"

module RR
describe MockProbeCreator, :shared => true do
  before(:each) do
    @space = Space.new
    @subject = Object.new
  end

  it "initializes creator with passed in object" do
    @creator.subject.should === @subject
  end
end

describe MockProbeCreator, "#create" do
  it_should_behave_like "RR::MockProbeCreator"
  
  before do
    @subject = Object.new
    @creator = MockProbeCreator.new(@space, @subject)
  end

  it "sets expectations on the subject while calling the original method" do
    def @subject.foobar(*args); :baz; end
    @creator.create(:foobar,1, 2).twice
    @subject.foobar(1, 2).should == :baz
    @subject.foobar(1, 2).should == :baz
    proc {@subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
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