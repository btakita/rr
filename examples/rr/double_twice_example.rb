dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR

describe Double, "#twice" do
  before do
    @space = RR::Space.new
    @object = Object.new
    @method_name = :foobar
    @double = @space.create_double(@object, @method_name) {}
  end
  
  it "sets up a Times Called Expectation with 2" do
    @double.twice
    @object.foobar
    @object.foobar
    proc {@object.foobar}.should raise_error(Expectations::TimesCalledExpectationError)
  end
end

end