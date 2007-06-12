dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
  describe ExpectationProxy, "#with" do
    before do
      @space = RR::Space.new
      @object = Object.new
      @method_name = :foobar
      @double = @space.create_double(@object, @method_name) {}
      @proxy = ExpectationProxy.new(@double)
    end

    it "sets an ArgumentEqualityExpectation" do
      @proxy.with(1).should === @proxy
      @object.foobar(1)
      proc {@object.foobar(2)}.should raise_error(RR::Expectations::ArgumentEqualityExpectationError)
    end
  end

  describe ExpectationProxy, "#once" do
    before do
      @space = RR::Space.new
      @object = Object.new
      @method_name = :foobar
      @double = @space.create_double(@object, @method_name) {}
      @proxy = ExpectationProxy.new(@double)
    end

    it "sets up a Times Called Expectation with 1" do
      @proxy.once.should === @proxy
      @object.foobar
      proc {@object.foobar}.should raise_error(Expectations::TimesCalledExpectationError)
    end
  end

  describe ExpectationProxy, "#twice" do
    before do
      @space = RR::Space.new
      @object = Object.new
      @method_name = :foobar
      @double = @space.create_double(@object, @method_name) {}
      @proxy = ExpectationProxy.new(@double)
    end

    it "sets up a Times Called Expectation with 2" do
      @proxy.twice.should === @proxy
      @object.foobar
      @object.foobar
      proc {@object.foobar}.should raise_error(Expectations::TimesCalledExpectationError)
    end
  end

  describe ExpectationProxy, "#returns" do
    before do
      @space = RR::Space.new
      @object = Object.new
      @method_name = :foobar
      @double = @space.create_double(@object, @method_name) {}
      @proxy = ExpectationProxy.new(@double)
    end

    it "sets the value of the method" do
      @proxy.returns {:baz}.should === @proxy
      @object.foobar.should == :baz
    end
  end

  describe ExpectationProxy, "#original_method" do
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
      @proxy = ExpectationProxy.new(@double)

      @proxy.original_method.call.should == :original_foobar
    end
  end
end
