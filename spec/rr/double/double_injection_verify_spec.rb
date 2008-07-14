require "spec/spec_helper"

module RR
  describe DoubleInjection, "#verify" do
    it_should_behave_like "Swapped Space"
    before do
      @space = Space.instance
      @object = Object.new
      @method_name = :foobar
      @object.methods.should_not include(@method_name.to_s)
      @double_injection = @space.double_injection(@object, @method_name)
    end

    it "verifies each double was met" do
      double = Double.new(@double_injection, DoubleDefinition.new(creator = Object.new))
      @double_injection.register_double double

      double.with(1).once.returns {nil}
      lambda {@double_injection.verify}.should raise_error(Errors::TimesCalledError)
      @object.foobar(1)
      lambda {@double_injection.verify}.should_not raise_error
    end
  end
end
