require "examples/example_helper"

module RR
describe Space, "#mock_creator" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object = Object.new
  end

  it "creates a MockCreator" do
    creator = @space.mock_creator(@object)
    creator.foobar(1) {:baz}
    @object.foobar(1).should == :baz
    proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
  end

  it "creates a mock Scenario for method when passed a second argument" do
    creator = @space.mock_creator(@object, :foobar).with(1) {:baz}
    @object.foobar(1).should == :baz
    proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
  end

  it "raises error if passed a method name and a block" do
    proc do
      @space.mock_creator(@object, :foobar) {}
    end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
  end

  it "uses block definition when passed a block" do
    creator = @space.mock_creator(@object) do |c|
      c.foobar(1) {:baz}
    end
    @object.foobar(1).should == :baz
    proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
  end
end

describe Space, "#stub_creator" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
  end

  it "creates a StubCreator" do
    creator = @space.stub_creator(@object)
    creator.foobar {:baz}
    @object.foobar.should == :baz
    @object.foobar.should == :baz
  end

  it "creates a stub Scenario for method when passed a second argument" do
    creator = @space.stub_creator(@object, :foobar).with(1) {:baz}
    @object.foobar(1).should == :baz
    @object.foobar(1).should == :baz
  end

  it "raises error if passed a method name and a block" do
    proc do
      @space.stub_creator(@object, :foobar) {}
    end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
  end

  it "uses block definition when passed a block" do
    creator = @space.stub_creator(@object) do |c|
      c.foobar(1) {:return_value}
      c.foobar.with_any_args {:default}
      c.baz(1) {:baz_value}
    end
    @object.foobar(1).should == :return_value
    @object.foobar.should == :default
    proc {@object.baz.should == :return_value}.should raise_error
  end
end

describe Space, "#create_mock_probe_creator" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    def @object.foobar(*args)
      :original_foobar
    end
  end

  it "creates a MockProbeCreator" do
    creator = @space.create_mock_probe_creator(@object)
    creator.foobar(1)
    @object.foobar(1).should == :original_foobar
    proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
  end

  it "uses block definition when passed a block" do
    creator = @space.create_mock_probe_creator(@object) do |c|
      c.foobar(1)
    end
    @object.foobar(1).should == :original_foobar
    proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
  end
end

describe Space, "#create_stub_probe_creator" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    def @object.foobar(*args)
      :original_foobar
    end
  end

  it "creates a StubProbeCreator" do
    creator = @space.create_stub_probe_creator(@object)
    creator.foobar
    @object.foobar(1).should == :original_foobar
    @object.foobar(1).should == :original_foobar
  end

  it "uses block definition when passed a block" do
    creator = @space.create_stub_probe_creator(@object) do |c|
      c.foobar(1)
    end
    @object.foobar(1).should == :original_foobar
    @object.foobar(1).should == :original_foobar
  end
end

describe Space, "#create_do_not_allow_creator" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object = Object.new
  end

  it "creates a MockCreator" do
    creator = @space.create_do_not_allow_creator(@object)
    creator.foobar(1)
    proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
  end

  it "uses block definition when passed a block" do
    creator = @space.create_do_not_allow_creator(@object) do |c|
      c.foobar(1)
    end
    proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
  end
end

describe Space, "#create_scenario" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
  end

  it "creates a Scenario and registers it to the double" do
    double = @space.create_double(@object, @method_name)
    def double.scenarios
      @scenarios
    end

    scenario = @space.create_scenario(double)
    double.scenarios.should include(scenario)
  end
end

describe Space, "#create_double" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
  end

  it "creates a new double when existing object == but not === with the same method name" do
    object1 = []
    object2 = []
    (object1 === object2).should be_true
    object1.__id__.should_not == object2.__id__

    double1 = @space.create_double(object1, :foobar)
    double2 = @space.create_double(object2, :foobar)
    
    double1.should_not == double2
  end
end

describe Space, "#create_double when double does not exist" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object = Object.new
    def @object.foobar(*args)
      :original_foobar
    end
    @method_name = :foobar
  end

  it "returns double and adds double to double list when method_name is a symbol" do
    double = @space.create_double(@object, @method_name)
    @space.doubles[@object][@method_name].should === double
    double.space.should === @space
    double.object.should === @object
    double.method_name.should === @method_name
  end

  it "returns double and adds double to double list when method_name is a string" do
    double = @space.create_double(@object, 'foobar')
    @space.doubles[@object][@method_name].should === double
    double.space.should === @space
    double.object.should === @object
    double.method_name.should === @method_name
  end

  it "overrides the method when passing a block" do
    double = @space.create_double(@object, @method_name)
    @object.methods.should include("__rr__#{@method_name}")
  end
end

describe Space, "#create_double when double exists" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object = Object.new
    def @object.foobar(*args)
      :original_foobar
    end
    @method_name = :foobar
  end

  it "returns the existing double" do
    original_foobar_method = @object.method(:foobar)
    double = @space.create_double(@object, 'foobar')

    double.original_method.should == original_foobar_method

    @space.create_double(@object, 'foobar').should === double

    double.reset
    @object.foobar.should == :original_foobar
  end
end
end
