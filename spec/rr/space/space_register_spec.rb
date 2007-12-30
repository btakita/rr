require "spec/spec_helper"

module RR
  describe Space, "#register_ordered_scenario" do
    it_should_behave_like "RR::Space"

    before(:each) do
      @space = Space.new
      @original_space = Space.instance
      Space.instance = @space
      @object = Object.new
      @method_name = :foobar
      @double_insertion = @space.double_insertion(@object, @method_name)
    end

    after(:each) do
      Space.instance = @original_space
    end

    it "adds the ordered scenario to the ordered_scenarios collection" do
      scenario1 = @space.scenario(@double_insertion)

      @space.ordered_scenarios.should == []
      @space.register_ordered_scenario scenario1
      @space.ordered_scenarios.should == [scenario1]

      scenario2 = @space.scenario(@double_insertion)
      @space.register_ordered_scenario scenario2
      @space.ordered_scenarios.should == [scenario1, scenario2]
    end
  end
end
