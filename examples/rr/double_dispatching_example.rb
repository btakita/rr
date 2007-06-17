#dir = File.dirname(__FILE__)
#require "#{dir}/../example_helper"
#
#module RR
#describe Double, " method dispatching" do
#  before do
#    @space = Space.new
#    @object = Object.new
#    @method_name = :foobar
#    @object.methods.should_not include(@method_name.to_s)
#    @double = @space.create_double(@object, @method_name) {}
#  end
#
#  it "dispatches to Scenario that has an exact match" do
#    scenario_with_exact_match = Scenario.new(@double)
#    scenario_with_exact_match.with(:exact_match_1).returns {:exact_match_1}
#    scenario_with_no_match = Scenario.new(@double)
#    scenario_with_no_match.with("nothing that matches").returns {:no_match}
#    scenario_with_no_match = Scenario.new(@double)
#    scenario_with_no_match.with(:exact_match_2).returns {:exact_match_2}
#
#    @object.foobar(:exact_match_1).should == :exact_match_1
#    @object.foobar(:exact_match_2).should == :exact_match_2
#  end
#end
#end