dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

describe RR::Double, "#add_expectation", :shared => true do
  before do
    @space = RR::Space.new
    @object = Object.new
    @method_name = :foobar
    @double = @space.create_double(@object, @method_name) {}
  end
end

describe RR::Double, "#add_expectation ArgumentEqualityExpectation" do
  it_should_behave_like "RR::Double#add_expectation"

  it "fails" do
    @expectation = RR::Expectations::ArgumentEqualityExpectation.new(1)
    @double.add_expectation(@expectation)
    proc {@object.foobar(2)}.should raise_error(RR::Expectations::ArgumentEqualityExpectationError)
  end

  it "succeeds" do
    @expectation = RR::Expectations::ArgumentEqualityExpectation.new(1)
    @double.add_expectation(@expectation)
    @object.foobar(1)
  end

  it "overrides previous ArgumentEqualityExpectation" do
    expectation0 = RR::Expectations::ArgumentEqualityExpectation.new(0)
    @double.add_expectation(expectation0)

    proc {@object.foobar(1)}.should raise_error(RR::Expectations::ArgumentEqualityExpectationError)

    expectation1 = RR::Expectations::ArgumentEqualityExpectation.new(1)
    @double.add_expectation(expectation1)
    @object.foobar(1)
  end
end

describe RR::Double, "#add_expectation TimesCalledExpectation" do
  it_should_behave_like "RR::Double#add_expectation"

  it "fails" do
    @expectation = RR::Expectations::TimesCalledExpectation.new(1)
    @double.add_expectation(@expectation)
    proc {@double.verify}.should raise_error(RR::Expectations::TimesCalledExpectationError)
  end

  it "succeeds" do
    @expectation = RR::Expectations::TimesCalledExpectation.new(1)
    @double.add_expectation(@expectation)
    @object.foobar
    @double.verify
  end

  it "overrides previous ArgumentEqualityExpectation" do
    expectation0 = RR::Expectations::TimesCalledExpectation.new(0)
    @double.add_expectation(expectation0)

    proc {@object.foobar}.should raise_error(RR::Expectations::TimesCalledExpectationError)

    expectation1 = RR::Expectations::TimesCalledExpectation.new(1)
    @double.add_expectation(expectation1)
    @object.foobar
  end
end
