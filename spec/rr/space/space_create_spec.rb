require "spec/spec_helper"

module RR
  describe Space, "#double_method_proxy", :shared => true do
    it_should_behave_like "RR::Space"

    before do
      @space = Space.new
      @object = Object.new
    end

    it "creates a DoubleMethodProxy" do
      proxy = @space.double_method_proxy(@creator, @object)
      proxy.should be_instance_of(DoubleMethodProxy)
    end

    it "sets creator to passed in creator" do
      proxy = @space.double_method_proxy(@creator, @object)
      class << proxy
        attr_reader :creator
      end
      proxy.creator.should === @creator
    end

    it "raises error if passed a method name and a block" do
      proc do
        @space.double_method_proxy(@creator, @object, :foobar) {}
      end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
    end
  end

  describe Space, "#double_method_proxy with a Mock strategy" do
    it_should_behave_like "RR::Space#double_method_proxy"

    before do
      @creator = @space.double_creator
      @creator.mock
    end

    it "creates a mock Double for method when passed a second argument" do
      @space.double_method_proxy(@creator, @object, :foobar).with(1) {:baz}
      @object.foobar(1).should == :baz
      proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
    end

    it "uses block definition when passed a block" do
      @space.double_method_proxy(@creator, @object) do |c|
        c.foobar(1) {:baz}
      end
      @object.foobar(1).should == :baz
      proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
    end
  end

  describe Space, "#double_method_proxy with a Stub strategy" do
    it_should_behave_like "RR::Space#double_method_proxy"

    before do
      @creator = @space.double_creator
      @creator.stub
    end

    it "creates a stub Double for method when passed a second argument" do
      @space.double_method_proxy(@creator, @object, :foobar).with(1) {:baz}
      @object.foobar(1).should == :baz
      @object.foobar(1).should == :baz
    end

    it "uses block definition when passed a block" do
      @space.double_method_proxy(@creator, @object) do |c|
        c.foobar(1) {:return_value}
        c.foobar.with_any_args {:default}
        c.baz(1) {:baz_value}
      end
      @object.foobar(1).should == :return_value
      @object.foobar.should == :default
      proc {@object.baz.should == :return_value}.should raise_error
    end
  end

  describe Space, "#double_method_proxy with a Mock Proxy strategy" do
    it_should_behave_like "RR::Space#double_method_proxy"

    before do
      @creator = @space.double_creator
      @creator.mock.proxy
      def @object.foobar(*args)
        :original_foobar
      end
    end

    it "creates a mock proxy Double for method when passed a second argument" do
      @space.double_method_proxy(@creator, @object, :foobar).with(1)
      @object.foobar(1).should == :original_foobar
      proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
    end

    it "uses block definition when passed a block" do
      @space.double_method_proxy(@creator, @object) do |c|
        c.foobar(1)
      end
      @object.foobar(1).should == :original_foobar
      proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
    end
  end

  describe Space, "#double_method_proxy with a Stub proxy strategy" do
    it_should_behave_like "RR::Space#double_method_proxy"

    before do
      @creator = @space.double_creator
      @creator.stub.proxy
      def @object.foobar(*args)
        :original_foobar
      end
    end

    it "creates a stub proxy Double for method when passed a second argument" do
      @space.double_method_proxy(@creator, @object, :foobar)
      @object.foobar(1).should == :original_foobar
      @object.foobar(1).should == :original_foobar
    end

    it "uses block definition when passed a block" do
      @space.double_method_proxy(@creator, @object) do |c|
        c.foobar(1)
      end
      @object.foobar(1).should == :original_foobar
      @object.foobar(1).should == :original_foobar
    end
  end

  describe Space, "#double_method_proxy with a Do Not Allow strategy" do
    it_should_behave_like "RR::Space#double_method_proxy"

    before do
      @creator = @space.double_creator
      @creator.dont_allow
    end

    it "creates a do not allow Double for method when passed a second argument" do
      @space.double_method_proxy(@creator, @object, :foobar).with(1)
      proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
    end

    it "uses block definition when passed a block" do
      @space.double_method_proxy(@creator, @object) do |c|
        c.foobar(1)
      end
      proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
    end
  end

  describe Space, "#double_creator" do
    it_should_behave_like "RR::Space"

    before do
      @space = Space.new
      @object = Object.new
      @creator = @space.double_creator
    end

    it "sets the space" do
      @creator.space.should === @space
    end

    it "creates a DoubleCreator" do
      @creator.should be_instance_of(DoubleCreator)
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

      double = @space.double(double_injection)
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