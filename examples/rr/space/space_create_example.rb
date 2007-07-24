require "examples/example_helper"

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

describe Space, "#scenario_method_proxy with a Mock Probe strategy" do
  it_should_behave_like "RR::Space#scenario_method_proxy"

  before do
    @creator = @space.scenario_creator
    @creator.mock.probe
    def @object.foobar(*args)
      :original_foobar
    end
  end

  it "creates a mock probe Scenario for method when passed a second argument" do
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

describe Space, "#scenario_method_proxy with a Stub Probe strategy" do
  it_should_behave_like "RR::Space#scenario_method_proxy"

  before do
    @creator = @space.scenario_creator
    @creator.stub.probe
    def @object.foobar(*args)
      :original_foobar
    end
  end

  it "creates a stub probe Scenario for method when passed a second argument" do
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

  it "creates a Scenario and registers it to the double" do
    double = @space.double(@object, @method_name)
    def double.scenarios
      @scenarios
    end

    scenario = @space.scenario(double)
    double.scenarios.should include(scenario)
  end
end

describe Space, "#double" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
  end

  it "creates a new double when existing object == but not === with the same method name" do
    object1 = []
    object2 = []
    (object1 === object2).should be_true
    object1.__id__.should_not == object2.__id__

    double1 = @space.double(object1, :foobar)
    double2 = @space.double(object2, :foobar)
    
    double1.should_not == double2
  end
end

describe Space, "#double when double does not exist" do
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
    double = @space.double(@object, @method_name)
    @space.double(@object, @method_name).should === double
    double.space.should === @space
    double.object.should === @object
    double.method_name.should === @method_name
  end

  it "returns double and adds double to double list when method_name is a string" do
    double = @space.double(@object, 'foobar')
    @space.double(@object, @method_name).should === double
    double.space.should === @space
    double.object.should === @object
    double.method_name.should === @method_name
  end

  it "overrides the method when passing a block" do
    double = @space.double(@object, @method_name)
    @object.methods.should include("__rr__#{@method_name}")
  end
end

describe Space, "#double when double exists" do
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
    double = @space.double(@object, 'foobar')

    double.original_method.should == original_foobar_method

    @space.double(@object, 'foobar').should === double

    double.reset
    @object.foobar.should == :original_foobar
  end
end

describe Space, "#occurance" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @subject = Object.new
    @double = @space.double(@subject, :foobar)
    @scenario = @space.scenario(@double)
  end

  it "creates an Occurance" do
    occurance = @space.occurance(@double, @scenario)
    occurance.class.should == Occurance
    occurance.double.should == @double
    occurance.scenario.should == @scenario
  end
end
end