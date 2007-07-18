require "examples/example_helper"

module RR
describe Space, "#create_mock_creator" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object = Object.new
  end

  it "creates a MockCreator" do
    creator = @space.create_mock_creator(@object)
    creator.foobar(1) {:baz}
    @object.foobar(1).should == :baz
    proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
  end

  it "uses block definition when passed a block" do
    creator = @space.create_mock_creator(@object) do |c|
      c.foobar(1) {:baz}
    end
    @object.foobar(1).should == :baz
    proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
  end
end

describe Space, "#create_stub_creator" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
  end

  it "creates a StubCreator" do
    creator = @space.create_stub_creator(@object)
    creator.foobar {:baz}
    @object.foobar.should == :baz
    @object.foobar.should == :baz
  end

  it "uses block definition when passed a block" do
    creator = @space.create_stub_creator(@object) do |c|
      c.foobar(1) {:return_value}
      c.foobar.with_any_args {:default}
      c.baz(1) {:baz_value}
    end
    @object.foobar(1).should == :return_value
    @object.foobar.should == :default
    proc {@object.baz.should == :return_value}.should raise_error
  end
end

describe Space, "#create_probe_creator" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
    def @object.foobar(*args)
      :original_foobar
    end
  end

  it "creates a ProbeMockCreator" do
    creator = @space.create_probe_creator(@object)
    creator.foobar(1)
    @object.foobar(1).should == :original_foobar
    proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
  end

  it "uses block definition when passed a block" do
    creator = @space.create_probe_creator(@object) do |c|
      c.foobar(1)
    end
    @object.foobar(1).should == :original_foobar
    proc {@object.foobar(1)}.should raise_error(Errors::TimesCalledError)
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
