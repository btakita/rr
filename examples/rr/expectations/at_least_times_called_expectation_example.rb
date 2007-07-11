dir = File.dirname(__FILE__)
require "#{dir}/../../example_helper"

module RR
module Expectations
describe AtLeastTimesCalledExpectation, :shared => true do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    @double = @space.create_double(@object, @method_name)
    @scenario = @space.create_scenario(@double)
    @scenario.with_any_args
  end

  def raises_expectation_error(&block)
    proc {block.call}.should raise_error(Errors::TimesCalledError)
  end
end

describe AtLeastTimesCalledExpectation, "#verify" do
  it_should_behave_like "RR::Expectations::AtLeastTimesCalledExpectation"

  it "returns true when times called exactly matches passed in value" do
    @expectation = AtLeastTimesCalledExpectation.new(2)
    @expectation.verify_input
    @expectation.verify_input
    @expectation.verify.should == true
  end

  it "returns true when times called greater than passed in value" do
    @expectation = AtLeastTimesCalledExpectation.new(2)

    @expectation.verify_input
    @expectation.verify_input
    @expectation.verify_input
    @expectation.verify.should == true
  end

  it "returns false when times called less than passed in value" do
    @expectation = AtLeastTimesCalledExpectation.new(2)

    @expectation.verify_input
    @expectation.verify.should == false
  end
end

describe AtLeastTimesCalledExpectation, "#verify!" do
  it_should_behave_like "RR::Expectations::AtLeastTimesCalledExpectation"

  it "returns true when times called exactly matches passed in value" do
    @expectation = AtLeastTimesCalledExpectation.new(2)
    @expectation.verify_input
    @expectation.verify_input
    @expectation.verify!
  end

  it "returns true when times called greater than passed in value" do
    @expectation = AtLeastTimesCalledExpectation.new(2)

    @expectation.verify_input
    @expectation.verify_input
    @expectation.verify_input
    @expectation.verify!
  end

  it "returns false when times called less than passed in value" do
    @expectation = AtLeastTimesCalledExpectation.new(2)

    @expectation.verify_input
    proc {@expectation.verify!}.should raise_error(Errors::TimesCalledError)
  end

  it "has a backtrace to where the AtLeastTimesCalledExpectation was instantiated on failure" do
    @expectation = AtLeastTimesCalledExpectation.new(2)
    error = nil
    begin
      @expectation.verify!
    rescue Errors::TimesCalledError => e
      error = e
    end
    e.backtrace.first.should include(__FILE__)
    e.backtrace.first.should include(":#{@expected_line}")
  end
end
end
end
