dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
  describe Double, "#bind with an existing method" do
    before do
      @space = Space.new
      @object = Object.new
      @method_name = :foobar
      def @object.foobar; :original_foobar; end
      @object.methods.should include(@method_name.to_s)
      @double = Double.new(@space, @object, @method_name)
    end

    it "overrides the original method with the double's dispatching methods" do
      @object.respond_to?(:__rr__foobar__rr__).should == false
      @double.bind
      @object.respond_to?(:__rr__foobar__rr__).should == true

      rr_foobar_called = false
      (class << @object; self; end).class_eval do
        define_method :__rr__foobar__rr__ do
          rr_foobar_called = true
        end
      end

      rr_foobar_called.should == false
      @object.foobar
      rr_foobar_called.should == true
    end
  end
end