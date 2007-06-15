dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
  describe Scenario, :shared => true do
    before do
      @space = RR::Space.new
      @object = Object.new
      @method_name = :foobar
      @double = @space.create_double(@object, @method_name) {}
      @builder = Scenario.new(@double)
    end
  end

  describe Scenario, "#with" do
    it_should_behave_like "RR::Scenario"

    it "sets an ArgumentEqualityExpectation" do
      @builder.with(1).should === @builder
      @object.foobar(1)
      proc {@object.foobar(2)}.should raise_error(RR::Expectations::ArgumentEqualityExpectationError)
    end
  end

  describe Scenario, "#once" do
    it_should_behave_like "RR::Scenario"

    it "sets up a Times Called Expectation with 1" do
      @builder.once.should === @builder
      @object.foobar
      proc {@object.foobar}.should raise_error(Expectations::TimesCalledExpectationError)
    end
  end

  describe Scenario, "#twice" do
    it_should_behave_like "RR::Scenario"

    it "sets up a Times Called Expectation with 2" do
      @builder.twice.should === @builder
      @object.foobar
      @object.foobar
      proc {@object.foobar}.should raise_error(Expectations::TimesCalledExpectationError)
    end
  end

  describe Scenario, "#times" do
    it_should_behave_like "RR::Scenario"

    it "sets up a Times Called Expectation with passed in times" do
      @builder.times(3).should === @builder
      @object.foobar
      @object.foobar
      @object.foobar
      proc {@object.foobar}.should raise_error(Expectations::TimesCalledExpectationError)
    end
  end

  describe Scenario, "#returns" do
    it_should_behave_like "RR::Scenario"

    it "sets the value of the method" do
      @builder.returns {:baz}.should === @builder
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
      @builder = Scenario.new(@double)

      @builder.original_method.call.should == :original_foobar
    end
  end
end
