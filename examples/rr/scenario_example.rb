dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
  describe Scenario, :shared => true do
    before do
      @space = RR::Space.new
      @object = Object.new
      @method_name = :foobar
      @double = @space.create_double(@object, @method_name) {}
      @scenario = Scenario.new(@double)
    end
  end

  describe Scenario, "#with" do
    it_should_behave_like "RR::Scenario"

    it "sets an ArgumentEqualityExpectation" do
      @scenario.with(1).should === @scenario
      @object.foobar(1)
      proc {@object.foobar(2)}.should raise_error(RR::Expectations::ArgumentEqualityExpectationError)
    end
  end

  describe Scenario, "#once" do
    it_should_behave_like "RR::Scenario"

    it "sets up a Times Called Expectation with 1" do
      @scenario.once.should === @scenario
      @object.foobar
      proc {@object.foobar}.should raise_error(Expectations::TimesCalledExpectationError)
    end
  end

  describe Scenario, "#twice" do
    it_should_behave_like "RR::Scenario"

    it "sets up a Times Called Expectation with 2" do
      @scenario.twice.should === @scenario
      @object.foobar
      @object.foobar
      proc {@object.foobar}.should raise_error(Expectations::TimesCalledExpectationError)
    end
  end

  describe Scenario, "#times" do
    it_should_behave_like "RR::Scenario"

    it "sets up a Times Called Expectation with passed in times" do
      @scenario.times(3).should === @scenario
      @object.foobar
      @object.foobar
      @object.foobar
      proc {@object.foobar}.should raise_error(Expectations::TimesCalledExpectationError)
    end
  end

  describe Scenario, "#returns" do
    it_should_behave_like "RR::Scenario"

    it "sets the value of the method" do
      @scenario.returns {:baz}.should === @scenario
      @object.foobar.should == :baz
    end
  end

  describe Scenario, "#original_method" do
    before do
      @space = RR::Space.new
      @object = Object.new
      @method_name = :foobar
    end

    it "returns the original method of the object when one exists" do
      def @object.foobar
        :original_foobar
      end
      @double = @space.create_double(@object, @method_name) {}
      @scenario = Scenario.new(@double)

      @scenario.original_method.call.should == :original_foobar
    end
  end
#
#  describe Scenario, "#call" do
#    before do
#      @space = RR::Space.new
#      @object = Object.new
#      @method_name = :foobar
#    end
#
#    it "calls the return proc when scheduled to call a proc" do
#      @scenario = @space.create_scenario(@object, @method_name)
#
#      @scenario.call
#    end
#  end
end
