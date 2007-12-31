require "spec/spec_helper"

module RR
  describe DoubleInjection, :shared => true do
    it "sets up object and method_name" do
      @double_insertion.object.should === @object
      @double_insertion.method_name.should == @method_name.to_sym
    end
  end

  describe DoubleInjection, "#initialize where method_name is a symbol" do
    it_should_behave_like "RR::DoubleInjection"

    before do
      @space = Space.new
      @object = Object.new
      @method_name = :foobar
      @object.methods.should_not include(@method_name.to_s)
      @double_insertion = DoubleInjection.new(@space, @object, @method_name)
    end
  end

  describe DoubleInjection, "#initialize where method_name is a string" do
    it_should_behave_like "RR::DoubleInjection"

    before do
      @space = Space.new
      @object = Object.new
      @method_name = 'foobar'
      @object.methods.should_not include(@method_name)
      @double_insertion = DoubleInjection.new(@space, @object, @method_name)
    end
  end

  describe DoubleInjection, "#initialize where method does not exist on object" do
    it_should_behave_like "RR::DoubleInjection"

    before do
      @space = Space.new
      @object = Object.new
      @method_name = :foobar
      @object.methods.should_not include(@method_name.to_s)
      @double_insertion = DoubleInjection.new(@space, @object, @method_name)
    end

    it "object does not have original method" do
      @double_insertion.object_has_original_method?.should be_false
    end
  end

  describe DoubleInjection, "#initialize where method exists on object" do
    it_should_behave_like "RR::DoubleInjection"

    before do
      @space = Space.new
      @object = Object.new
      @method_name = :to_s
      @object.methods.should include(@method_name.to_s)
      @double_insertion = DoubleInjection.new(@space, @object, @method_name)
    end

    it "has a original_method" do
      @double_insertion.object_has_original_method?.should be_true
    end
  end
end
