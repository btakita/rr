require "spec/spec_helper"

module RR
  describe DoubleInjection, "#register_double" do
    before do
      @space = Space.new
      @object = Object.new
      @method_name = :foobar
      @object.methods.should_not include(@method_name.to_s)
      @double_injection = DoubleInjection.new(@object, @method_name)
      def @double_injection.doubles
        @doubles
      end
    end

    it "adds the double to the doubles list" do
      double = Double.new(@space, @double_injection, @space.double_definition)

      @double_injection.doubles.should_not include(double)
      @double_injection.register_double double
      @double_injection.doubles.should include(double)
    end
  end
end
