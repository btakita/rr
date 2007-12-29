require "spec/spec_helper"

module RR
  describe ScenarioMethodProxy, "initializes proxy with passed in creator", :shared => true do
    it "initializes proxy with passed in creator" do
      class << the_proxy
        attr_reader :creator
      end
      the_proxy.creator.should === creator
    end
  end

  describe ScenarioMethodProxy do
    attr_reader :space, :subject, :creator, :the_proxy
    before(:each) do
      @space = Space.new
      @subject = Object.new
      @creator = space.scenario_creator
      creator.mock
    end

    describe ".new without block" do
      it_should_behave_like "RR::ScenarioMethodProxy initializes proxy with passed in creator"
      before do
        @the_proxy = ScenarioMethodProxy.new(space, creator, subject)
      end

      it "clears out all methods from proxy" do
        proxy_subclass = Class.new(ScenarioMethodProxy) do
          def i_should_be_a_scenario
          end
        end
        proxy_subclass.instance_methods.should include('i_should_be_a_scenario')

        proxy = proxy_subclass.new(space, creator, subject)
        proxy.i_should_be_a_scenario.should be_instance_of(ScenarioDefinition)
      end
    end

    describe ".new with block" do
      it_should_behave_like "RR::ScenarioMethodProxy initializes proxy with passed in creator"
      before do
        @the_proxy = ScenarioMethodProxy.new(space, creator, subject) do |b|
          b.foobar(1, 2) {:one_two}
          b.foobar(1) {:one}
          b.foobar.with_any_args {:default}
          b.baz() {:baz_result}
        end
      end

      it "creates doubles" do
        subject.foobar(1, 2).should == :one_two
        subject.foobar(1).should == :one
        subject.foobar(:something).should == :default
        subject.baz.should == :baz_result
      end

      it "clears out all methods from proxy" do
        proxy_subclass = Class.new(ScenarioMethodProxy) do
          def i_should_be_a_scenario
          end
        end
        proxy_subclass.instance_methods.should include('i_should_be_a_scenario')

        proxy_subclass.new(space, creator, subject) do |m|
          m.i_should_be_a_scenario.should be_instance_of(ScenarioDefinition)
        end
      end
    end
  end
end