dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

describe RR::Double, "#verify_input", :shared => true do
  before do
    @space = RR::Space.new
    @object = Object.new
    @method_name = :foobar
    @object.methods.should_not include(@method_name.to_s)
    @double = @space.create_double(@object, @method_name) {}
  end
end

describe RR::Double, "#verify_input with no arguments" do
  it_should_behave_like "RR::Double#verify_input"

  it "verifies first argument passes" do
    expectation = RR::Expectations::ArgumentEqualityExpectation.new()
    @double.add_expectation expectation

    @object.foobar
    proc {@object.foobar(:not_valid)}.should raise_error(RR::Expectations::ArgumentEqualityExpectationError)
  end
end

describe RR::Double, "#verify_input with one argument" do
  it_should_behave_like "RR::Double#verify_input"

  it "verifies first argument passes" do
    expectation = RR::Expectations::ArgumentEqualityExpectation.new(:foo_arg1)
    @double.add_expectation expectation

    @object.foobar(:foo_arg1)
    proc {@object.foobar(:not_valid)}.should raise_error(RR::Expectations::ArgumentEqualityExpectationError)
  end
end

describe RR::Double, "#verify_input with multiple arguments" do
  it_should_behave_like "RR::Double#verify_input"

  it "verifies first argument passes" do
    expectation = RR::Expectations::ArgumentEqualityExpectation.new(:foo_arg1, :foo_arg2)
    @double.add_expectation expectation

    @object.foobar(:foo_arg1, :foo_arg2)
    proc {@object.foobar(:not_valid)}.should raise_error(RR::Expectations::ArgumentEqualityExpectationError)
  end
end
