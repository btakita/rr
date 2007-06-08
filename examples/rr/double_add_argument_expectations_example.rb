#dir = File.dirname(__FILE__)
#require "#{dir}/../example_helper"
#
#describe RR::Double, "#add_argument_expectation with one expectation" do
#  before do
#    @space = RR::Space.new
#    @object = Object.new
#    @method_name = :foobar
#    @double = @space.create_double(@object, @method_name) {}
#  end
#
#  it "sets an expectation that will pass" do
#    @double.add_argument_expectation(:foo, :bar)
#    @object.foobar(:foo, :bar)
#    @double.verify
#  end
#
#  it "wrong arguments are passed in sets expectation to fail" do
#    @double.add_argument_expectation(:foo, :bar)
#    proc {@object.foobar(:foo)}.should raise_error(ArgumentError)
#  end
#
#  it "never called sets expectation to fail"
#end
#
#describe RR::Double, "#add_argument_expectation with multiple expectation" do
#  before do
#    @space = RR::Space.new
#    @object = Object.new
#    @method_name = :foobar
#    @double = @space.create_double(@object, @method_name) {}
#  end
#
#  it "allows multiple expectations" do
#    @double.add_argument_expectation(:foo, :bar)
#    @double.add_argument_expectation(:baz)
#    @object.foobar(:foo, :bar)
#    @object.foobar(:baz)
#    @double.verify
#  end
#
#  it "never called sets expectation to fail"
#end
