require "examples/example_helper"

module RR
module Expectations
describe TimesCalledExpectation, " with failure", :shared => true do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

  before do
    @times = 0
    @matcher = TimesCalledMatchers::IntegerMatcher.new(@times)
    @expectation = TimesCalledExpectation.new(@scenario, @matcher)
  end
end

describe TimesCalledExpectation, "#attempt! with failure" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation with failure"
  
  it "raises error that includes the scenario" do
    proc do
      @expectation.attempt!
    end.should raise_error(
      Errors::TimesCalledError,
      "#{@scenario.formatted_name}\n#{@matcher.error_message(1)}"
    )
  end
end

describe TimesCalledExpectation, "#verify! with failure" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation with failure"
  
  it "raises error with passed in message prepended" do
    @expectation.instance_variable_set(:@times_called, 1)
    proc do
      @expectation.verify!
    end.should raise_error(
      Errors::TimesCalledError,
      "#{@scenario.formatted_name}\n#{@matcher.error_message(1)}"
    )
  end
end
end
end
