require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Doubles
    describe DoubleInjection do
      class << self
        define_method("cleans up by removing the __rr__method") do
          it "cleans up by removing the __rr__method" do
            @double_injection.bind
            @object.methods.should include("__rr__foobar")

            @double_injection.reset
            @object.methods.should_not include("__rr__foobar")
          end          
        end
      end

      describe "#reset" do
        context "when method does not exist" do
          send("cleans up by removing the __rr__method")

          before do
            @object = Object.new
            @method_name = :foobar
            @object.methods.should_not include(@method_name.to_s)
            @double_injection = DoubleInjection.new(@object, @method_name)
          end

          it "removes the method" do
            @double_injection.bind
            @object.methods.should include(@method_name.to_s)

            @double_injection.reset
            @object.methods.should_not include(@method_name.to_s)
            lambda {@object.foobar}.should raise_error(NoMethodError)
          end
        end

        context "when method exists" do
          send("cleans up by removing the __rr__method")

          before do
            @object = Object.new
            @method_name = :foobar
            def @object.foobar
              :original_foobar
            end
            @object.methods.should include(@method_name.to_s)
            @original_method = @object.method(@method_name)
            @double_injection = DoubleInjection.new(@object, @method_name)

            @double_injection.bind
            @object.methods.should include(@method_name.to_s)
          end

          it "rebind original method" do
            @double_injection.reset
            @object.methods.should include(@method_name.to_s)
            @object.foobar.should == :original_foobar
          end
        end

        context "when method with block exists" do
          send("cleans up by removing the __rr__method")

          before do
            @object = Object.new
            @method_name = :foobar
            def @object.foobar
              yield(:original_argument)
            end
            @object.methods.should include(@method_name.to_s)
            @original_method = @object.method(@method_name)
            @double_injection = DoubleInjection.new(@object, @method_name)

            @double_injection.bind
            @object.methods.should include(@method_name.to_s)
          end

          it "rebinds original method with block" do
            @double_injection.reset
            @object.methods.should include(@method_name.to_s)

            original_argument = nil
            @object.foobar do |arg|
              original_argument = arg
            end
            original_argument.should == :original_argument
          end
        end
      end
    end
  end
end
