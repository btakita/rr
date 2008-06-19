require "spec/spec_helper"

module RR
  describe Space, "#double_definition_creator" do
    it_should_behave_like "Swapped Space"
    it_should_behave_like "RR::Space"

    before do
      @space = Space.instance
      @object = Object.new
      @creator = @space.double_definition_creator
    end

    it "sets the space" do
      @creator.space.should === @space
    end

    it "creates a DoubleDefinitionCreator" do
      @creator.should be_instance_of(DoubleDefinitionCreator)
    end
  end

  describe Space, "#double" do
    it_should_behave_like "RR::Space"

    before do
      @space = Space.new
      @object = Object.new
      @method_name = :foobar
    end

    it "creates a Double and registers it to the double_injection" do
      double_injection = @space.double_injection(@object, @method_name)
      def double_injection.doubles
        @doubles
      end

      double = Double.new(double_injection)
      double_injection.doubles.should include(double)
    end
  end

  describe Space, "#double_injection" do
    it_should_behave_like "RR::Space"

    before do
      @space = Space.new
    end

    it "creates a new double_injection when existing object == but not === with the same method name" do
      object1 = []
      object2 = []
      (object1 === object2).should be_true
      object1.__id__.should_not == object2.__id__

      double1 = @space.double_injection(object1, :foobar)
      double2 = @space.double_injection(object2, :foobar)

      double1.should_not == double2
    end
  end

  describe Space, "#double_injection when double_injection does not exist" do
    it_should_behave_like "RR::Space"

    before do
      @space = Space.new
      @object = Object.new
      def @object.foobar(*args)
        :original_foobar
      end
      @method_name = :foobar
    end

    it "returns double_injection and adds double_injection to double_injection list when method_name is a symbol" do
      double_injection = @space.double_injection(@object, @method_name)
      @space.double_injection(@object, @method_name).should === double_injection
      double_injection.object.should === @object
      double_injection.method_name.should === @method_name
    end

    it "returns double_injection and adds double_injection to double_injection list when method_name is a string" do
      double_injection = @space.double_injection(@object, 'foobar')
      @space.double_injection(@object, @method_name).should === double_injection
      double_injection.object.should === @object
      double_injection.method_name.should === @method_name
    end

    it "overrides the method when passing a block" do
      double_injection = @space.double_injection(@object, @method_name)
      @object.methods.should include("__rr__#{@method_name}")
    end
  end

  describe Space, "#double_injection when double_injection exists" do
    it_should_behave_like "RR::Space"

    before do
      @space = Space.new
      @object = Object.new
      def @object.foobar(*args)
        :original_foobar
      end
      @method_name = :foobar
    end

    it "returns the existing double_injection" do
      original_foobar_method = @object.method(:foobar)
      double_injection = @space.double_injection(@object, 'foobar')

      double_injection.object_has_original_method?.should be_true

      @space.double_injection(@object, 'foobar').should === double_injection

      double_injection.reset
      @object.foobar.should == :original_foobar
    end
  end
end