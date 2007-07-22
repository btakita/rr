require "examples/example_helper"

module RR
describe ScenarioMethodProxy, :shared => true do
  before(:each) do
    @space = Space.new
    @subject = Object.new
    @creator = @space.scenario_creator
    @creator.mock
  end

  it "initializes proxy with passed in creator" do
    class << @proxy
      attr_reader :creator
    end
    @proxy.creator.should === @creator
  end
end

describe ScenarioMethodProxy, ".new without block" do
  it_should_behave_like "RR::ScenarioMethodProxy"

  before do
    @proxy = ScenarioMethodProxy.new(@space, @creator, @subject)
  end

  it "clears out all methods from proxy" do
    proxy_subclass = Class.new(ScenarioMethodProxy) do
      def i_should_be_a_scenario
      end
    end
    proxy_subclass.instance_methods.should include('i_should_be_a_scenario')

    proxy = proxy_subclass.new(@space, @creator, @subject)
    proxy.i_should_be_a_scenario.should be_instance_of(Scenario)
  end
end

describe ScenarioMethodProxy, ".new with block" do
  it_should_behave_like "RR::ScenarioMethodProxy"

  before do
    @proxy = ScenarioMethodProxy.new(@space, @creator, @subject) do |b|
      b.foobar(1, 2) {:one_two}
      b.foobar(1) {:one}
      b.foobar.with_any_args {:default}
      b.baz() {:baz_result}
    end
  end

  it "creates doubles" do
    @subject.foobar(1, 2).should == :one_two
    @subject.foobar(1).should == :one
    @subject.foobar(:something).should == :default
    @subject.baz.should == :baz_result
  end

  it "clears out all methods from proxy" do
    proxy_subclass = Class.new(ScenarioMethodProxy) do
      def i_should_be_a_scenario
      end
    end
    proxy_subclass.instance_methods.should include('i_should_be_a_scenario')

    proxy_subclass.new(@space, @creator, @subject) do |m|
      m.i_should_be_a_scenario.should be_instance_of(Scenario)
    end
  end
end

end