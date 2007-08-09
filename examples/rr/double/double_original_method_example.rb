require "examples/example_helper"

module RR
describe Double, "#original_method" do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :to_s
    @double = Double.new(@space, @object, @method_name)
    class << @double
      public :original_method_name
    end
  end

  it "returns true when method is still in object" do
    @double.bind
    @double.original_method.should == @object.method(@double.original_method_name)
  end
  
  it "returns false when respond_to is true and methods do not include method" do
    @double.bind
    @object.methods.should include(@double.original_method_name.to_s)
    class << @object
      undef_method :__rr__original_to_s
    end
    def @object.respond_to?(value)
      true
    end

    @double.original_method.should be_nil
  end
end
end
