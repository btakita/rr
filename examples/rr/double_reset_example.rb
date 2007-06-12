dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

describe RR::Double, "#reset", :shared => true do
  it "cleans up by removing the __rr__ method" do
    @double.bind
    @object.methods.should include("__rr__foobar__rr__")

    @double.reset
    @object.methods.should_not include("__rr__foobar__rr__")
  end
end

describe RR::Double, "#reset when method does not exist" do
  it_should_behave_like "RR::Double#reset"
  
  before do
    @space = RR::Space.new
    @object = Object.new
    @method_name = :foobar
    @object.methods.should_not include(@method_name.to_s)
    @double = RR::Double.new(@space, @object, @method_name)
  end

  it "removes the method" do
    @double.bind
    @double.double_method = proc {:baz}
    @object.foobar.should == :baz

    @double.reset
    @object.methods.should_not include(@method_name.to_s)
    proc {@object.foobar}.should raise_error(NoMethodError)
  end
end

describe RR::Double, "#reset when method exists" do
  it_should_behave_like "RR::Double#reset"
  
  before do
    @space = RR::Space.new
    @object = Object.new
    @method_name = :foobar
    def @object.foobar
      :original_foobar
    end
    @object.methods.should include(@method_name.to_s)
    @original_method = @object.method(@method_name)
    @double = RR::Double.new(@space, @object, @method_name)
  end

  it "removes the method" do
    @double.bind
    @double.double_method = proc {:baz}
    @object.foobar.should == :baz

    @double.reset
    @object.methods.should include(@method_name.to_s)
    @object.foobar.should == :original_foobar
  end
end
