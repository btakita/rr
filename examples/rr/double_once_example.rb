dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR

describe Double, "#once" do
  before do
    @space = RR::Space.new
    @object = Object.new
    @method_name = :foobar
    @double = @space.create_double(@object, @method_name) {}
  end
  
  it "sets up a Times Called Expectation with 2" do
    @double.once
    @object.foobar
    proc {@object.foobar}.should raise_error(Expectations::TimesCalledExpectationError)
  end
end

end