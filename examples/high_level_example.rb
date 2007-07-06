dir = File.dirname(__FILE__)
require "#{dir}/example_helper"

describe "RR", :shared => true do
  before(:each) do
    @obj = Object.new
    extend RR::Extensions::DoubleMethods
  end

  after(:each) do
    RR::Space.instance.reset_doubles
  end
end

describe "RR mock:" do
  it_should_behave_like "RR"

  it "mocks via inline call" do
    mock(@obj).to_s {"a value"}
    @obj.to_s.should == "a value"
    proc {@obj.to_s}.should raise_error(RR::Expectations::TimesCalledExpectationError)
  end

  it "allows ordering" do
    mock(@obj).to_s {"value 1"}.ordered
    mock(@obj).to_s {"value 2"}.twice.ordered
    @obj.to_s.should == "value 1"
    @obj.to_s.should == "value 2"
    @obj.to_s.should == "value 2"
    proc {@obj.to_s}.should raise_error(RR::Expectations::TimesCalledExpectationError)
  end

  it "mocks via block" do
    mock @obj do |c|
      c.to_s {"a value"}
      c.to_sym {:crazy}
    end
    @obj.to_s.should == "a value"
    @obj.to_sym.should == :crazy
  end
  
  it "has wildcard matchers" do
    mock(@obj).foobar(
      is_a(String),
      anything,
      numeric,
      boolean,
      duck_type(:to_s),
      /abc/
    ) {"value 1"}.twice
    @obj.foobar(
      'hello',
      Object.new,
      99,
      false,
      "My String",
      "Tabcola"
    ).should == "value 1"
    proc {@obj.foobar(:failure)}.should raise_error( ScenarioNotFoundError )
  end
end

describe "RR probe:" do
  it_should_behave_like "RR"

  it "probes via inline call" do
    expected_to_s_value = @obj.to_s
    probe(@obj).to_s
    @obj.to_s.should == expected_to_s_value
    proc {@obj.to_s}.should raise_error
  end

  it "allows ordering" do
    def @obj.to_s(arg)
      "Original to_s with arg #{arg}"
    end
    probe(@obj).to_s(:foo).ordered
    probe(@obj).to_s(:bar).twice.ordered

    @obj.to_s(:foo).should == "Original to_s with arg foo"
    @obj.to_s(:bar).should == "Original to_s with arg bar"
    @obj.to_s(:bar).should == "Original to_s with arg bar"
    proc {@obj.to_s(:bar)}.should raise_error(RR::Expectations::TimesCalledExpectationError)
  end

  it "probes via block" do
    def @obj.foobar_1(*args)
      :original_value_1
    end

    def @obj.foobar_2
      :original_value_2
    end

    probe @obj do |c|
      c.foobar_1(1)
      c.foobar_2
    end
    @obj.foobar_1(1).should == :original_value_1
    proc {@obj.foobar_1(:blah)}.should raise_error

    @obj.foobar_2.should == :original_value_2
    proc {@obj.foobar_2(:blah)}.should raise_error
  end
end

describe "RR stub:" do
  it_should_behave_like "RR"

  it "stubs via inline call" do
    stub(@obj).to_s {"a value"}
    @obj.to_s.should == "a value"
  end

  it "allows ordering" do
    stub(@obj).to_s {"value 1"}.once.ordered

    stub(@obj).to_s {"value 2"}.once.ordered

    @obj.to_s.should == "value 1"
    @obj.to_s.should == "value 2"
  end

  it "stubs via block" do
    stub @obj do |d|
      d.to_s {"a value"}
      d.to_sym {:crazy}
    end
    @obj.to_s.should == "a value"
    @obj.to_sym.should == :crazy
  end
end
