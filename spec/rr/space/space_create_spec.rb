require "spec/spec_helper"

module RR
  describe Space, "#scenario_method_proxy", :shared => true do
    it_should_behave_like "RR::Space"

    before do
      @space = Space.new
      @object = Object.new
    end

    it "creates a ScenarioMethodProxy" do
      proxy = @space.scenario_method_proxy(@creator, @object)
      proxy.should be_instance_of(ScenarioMethodProxy)
    end

    it "sets space to self" do
      proxy = @space.scenario_method_proxy(@creator, @object)
      class << proxy
        attr_reader :space
      end
      proxy.space.should === @space
    end

    it "sets creator to passed in creator" do
      proxy = @space.scenario_method_proxy(@creator, @object)
      class << proxy
        attr_reader :creator
      end
      proxy.creator.should === @creator
    end

    it "raises error if passed a method name and a block" do
      proc do
        @space.scenario_method_proxy(@creator, @object, :foobar) {}
      end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
    end
  end

  describe Space, "#scenario_method_proxy with a Mock strategy" do
    it_should_behave_like "RR::Space#scenario_method_proxy"

    before do
      @creator = @space.scenario_creator
      @creator.mock
    end

    it "creates a mock Scenario for method when passed a second argument" do
      @space.scenario_method_proxy(@creator, @object, :foobar).with(1) {:baz}
      @object.foobar(1).should == :baz
      proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
    end

    it "uses block definition when passed a block" do
      @space.scenario_method_proxy(@creator, @object) do |c|
        c.foobar(1) {:baz}
      end
      @object.foobar(1).should == :baz
      proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
    end
  end

  describe Space, "#scenario_method_proxy with a Stub strategy" do
    it_should_behave_like "RR::Space#scenario_method_proxy"

    before do
      @creator = @space.scenario_creator
      @creator.stub
    end

    it "creates a stub Scenario for method when passed a second argument" do
      @space.scenario_method_proxy(@creator, @object, :foobar).with(1) {:baz}
      @object.foobar(1).should == :baz
      @object.foobar(1).should == :baz
    end

    it "uses block definition when passed a block" do
      @space.scenario_method_proxy(@creator, @object) do |c|
        c.foobar(1) {:return_value}
        c.foobar.with_any_args {:default}
        c.baz(1) {:baz_value}
      end
      @object.foobar(1).should == :return_value
      @object.foobar.should == :default
      proc {@object.baz.should == :return_value}.should raise_error
    end
  end

  describe Space, "#scenario_method_proxy with a Mock Proxy strategy" do
    it_should_behave_like "RR::Space#scenario_method_proxy"

    before do
      @creator = @space.scenario_creator
      @creator.mock.proxy
      def @object.foobar(*args)
        :original_foobar
      end
    end

    it "creates a mock proxy Scenario for method when passed a second argument" do
      @space.scenario_method_proxy(@creator, @object, :foobar).with(1)
      @object.foobar(1).should == :original_foobar
      proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
    end

    it "uses block definition when passed a block" do
      @space.scenario_method_proxy(@creator, @object) do |c|
        c.foobar(1)
      end
      @object.foobar(1).should == :original_foobar
      proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
    end
  end

  describe Space, "#scenario_method_proxy with a Stub proxy strategy" do
    it_should_behave_like "RR::Space#scenario_method_proxy"

    before do
      @creator = @space.scenario_creator
      @creator.stub.proxy
      def @object.foobar(*args)
        :original_foobar
      end
    end

    it "creates a stub proxy Scenario for method when passed a second argument" do
      @space.scenario_method_proxy(@creator, @object, :foobar)
      @object.foobar(1).should == :original_foobar
      @object.foobar(1).should == :original_foobar
    end

    it "uses block definition when passed a block" do
      @space.scenario_method_proxy(@creator, @object) do |c|
        c.foobar(1)
      end
      @object.foobar(1).should == :original_foobar
      @object.foobar(1).should == :original_foobar
    end
  end

  describe Space, "#scenario_method_proxy with a Do Not Allow strategy" do
    it_should_behave_like "RR::Space#scenario_method_proxy"

    before do
      @creator = @space.scenario_creator
      @creator.do_not_call
    end

    it "creates a do not allow Scenario for method when passed a second argument" do
      @space.scenario_method_proxy(@creator, @object, :foobar).with(1)
      proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
    end

    it "uses block definition when passed a block" do
      @space.scenario_method_proxy(@creator, @object) do |c|
        c.foobar(1)
      end
      proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
    end
  end

  describe Space, "#scenario_creator" do
    it_should_behave_like "RR::Space"

    before do
      @space = Space.new
      @object = Object.new
      @creator = @space.scenario_creator
    end

    it "sets the space" do
      @creator.space.should === @space
    end

    it "creates a ScenarioCreator" do
      @creator.should be_instance_of(ScenarioCreator)
    end
  end

  describe Space, "#scenario" do
    it_should_behave_like "RR::Space"

    before do
      @space = Space.new
      @object = Object.new
      @method_name = :foobar
    end

    it "creates a Scenario and registers it to the double_insertion" do
      double_insertion = @space.double_insertion(@object, @method_name)
      def double_insertion.scenarios
        @scenarios
      end

      scenario = @space.scenario(double_insertion)
      double_insertion.scenarios.should include(scenario)
    end
  end

  describe Space, "#double_insertion" do
    it_should_behave_like "RR::Space"

    before do
      @space = Space.new
    end

    it "creates a new double_insertion when existing object == but not === with the same method name" do
      object1 = []
      object2 = []
      (object1 === object2).should be_true
      object1.__id__.should_not == object2.__id__

      double1 = @space.double_insertion(object1, :foobar)
      double2 = @space.double_insertion(object2, :foobar)

      double1.should_not == double2
    end
  end

  describe Space, "#double_insertion when double_insertion does not exist" do
    it_should_behave_like "RR::Space"

    before do
      @space = Space.new
      @object = Object.new
      def @object.foobar(*args)
        :original_foobar
      end
      @method_name = :foobar
    end

    it "returns double_insertion and adds double_insertion to double_insertion list when method_name is a symbol" do
      double_insertion = @space.double_insertion(@object, @method_name)
      @space.double_insertion(@object, @method_name).should === double_insertion
      double_insertion.space.should === @space
      double_insertion.object.should === @object
      double_insertion.method_name.should === @method_name
    end

    it "returns double_insertion and adds double_insertion to double_insertion list when method_name is a string" do
      double_insertion = @space.double_insertion(@object, 'foobar')
      @space.double_insertion(@object, @method_name).should === double_insertion
      double_insertion.space.should === @space
      double_insertion.object.should === @object
      double_insertion.method_name.should === @method_name
    end

    it "overrides the method when passing a block" do
      double_insertion = @space.double_insertion(@object, @method_name)
      @object.methods.should include("__rr__#{@method_name}")
    end
  end

  describe Space, "#double_insertion when double_insertion exists" do
    it_should_behave_like "RR::Space"

    before do
      @space = Space.new
      @object = Object.new
      def @object.foobar(*args)
        :original_foobar
      end
      @method_name = :foobar
    end

    it "returns the existing double_insertion" do
      original_foobar_method = @object.method(:foobar)
      double_insertion = @space.double_insertion(@object, 'foobar')

      double_insertion.object_has_original_method?.should be_true

      @space.double_insertion(@object, 'foobar').should === double_insertion

      double_insertion.reset
      @object.foobar.should == :original_foobar
    end
  end
end