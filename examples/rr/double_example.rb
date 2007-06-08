dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

describe RR::Double, :shared => true do
  it "sets up object and method_name" do
    @double.object.should === @object
    @double.method_name.should == @method_name.to_sym
  end
end

describe RR::Double, "#initialize where method_name is a symbol" do
  it_should_behave_like "RR::Double"

  before do
    @space = RR::Space.new
    @object = Object.new
    @method_name = :foobar
    @object.methods.should_not include(@method_name.to_s)
    @double = RR::Double.new(@space, @object, @method_name)
  end
end

describe RR::Double, "#initialize where method_name is a string" do
  it_should_behave_like "RR::Double"

  before do
    @space = RR::Space.new
    @object = Object.new
    @method_name = 'foobar'
    @object.methods.should_not include(@method_name)
    @double = RR::Double.new(@space, @object, @method_name)
  end
end

describe RR::Double, "#initialize where method does not exist on object" do
  it_should_behave_like "RR::Double"

  before do
    @space = RR::Space.new
    @object = Object.new
    @method_name = :foobar
    @object.methods.should_not include(@method_name.to_s)
    @double = RR::Double.new(@space, @object, @method_name)
  end

  it "has a nil original_method" do
    @double.original_method.should be_nil
  end
end

describe RR::Double, "#initialize where method exists on object" do
  it_should_behave_like "RR::Double"

  before do
    @space = RR::Space.new
    @object = Object.new
    @method_name = :to_s
    @object.methods.should include(@method_name.to_s)
    @double = RR::Double.new(@space, @object, @method_name)
  end

  it "has a nil original_method" do
    @double.original_method.should == @object.method(@method_name)
  end
end
