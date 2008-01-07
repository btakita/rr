require "spec/spec_helper"

module RR
  describe DoubleInjection, "#register_double" do
    before do
      @space = Space.new
      @object = Object.new
      @method_name = :foobar
      @object.methods.should_not include(@method_name.to_s)
      @double_insertion = DoubleInjection.new(@space, @object, @method_name)
      def @double_insertion.doubles
        @doubles
      end
    end

    it "adds the double to the doubles list" do
      double = Double.new(@space, @double_insertion, @space.double_definition)

      @double_insertion.doubles.should_not include(double)
      @double_insertion.register_double double
      @double_insertion.doubles.should include(double)
    end
  end
end
