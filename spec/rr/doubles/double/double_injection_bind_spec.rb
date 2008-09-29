require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Doubles
    describe DoubleInjection, "#bind with an existing method" do
      before do
        @object = Object.new
        @method_name = :foobar
        def @object.foobar;
          :original_foobar;
        end
        @original_method = @object.method(@method_name)
        @object.methods.should include(@method_name.to_s)
        @double_injection = DoubleInjection.new(@object, @method_name)
      end

      it "overrides the original method with the double_injection's dispatching methods" do
        @object.respond_to?(:__rr__foobar).should == false
        @double_injection.bind
        @object.respond_to?(:__rr__foobar).should == true

        rr_foobar_called = false
        (class << @object; self; end).class_eval do
          define_method :__rr__foobar do
            rr_foobar_called = true
          end
        end

        rr_foobar_called.should == false
        @object.foobar
        rr_foobar_called.should == true
      end

      it "stores original method in __rr__original_method_name" do
        @double_injection.bind
        @object.respond_to?(:__rr__original_foobar).should == true
        @object.method(:__rr__original_foobar).should == @original_method
      end
    end

    describe DoubleInjection, "#bind without an existing method" do
      before do
        @object = Object.new
        @method_name = :foobar
        @object.methods.should_not include(@method_name.to_s)
        @double_injection = DoubleInjection.new(@object, @method_name)
      end

      it "creates a new method with the double_injection's dispatching methods" do
        @object.respond_to?(:__rr__foobar).should == false
        @double_injection.bind
        @object.respond_to?(:__rr__foobar).should == true

        rr_foobar_called = false
        (class << @object; self; end).class_eval do
          define_method :__rr__foobar do
            rr_foobar_called = true
          end
        end

        rr_foobar_called.should == false
        @object.foobar
        rr_foobar_called.should == true
      end

      it "does not create method __rr__original_method_name" do
        @double_injection.bind
        @object.respond_to?(:__rr__original_foobar).should == false
      end
    end

    describe DoubleInjection, "#bind with ==" do
      before do
        @object = Object.new
        @method_name = :'=='
        @object.should respond_to(@method_name)
        @original_method = @object.method(@method_name)
        @object.methods.should include(@method_name.to_s)
        @double_injection = DoubleInjection.new(@object, @method_name)
      end

      it "overrides the original method with the double_injection's dispatching methods" do
        @object.respond_to?(:"__rr__#{@method_name}").should == false
        @double_injection.bind
        @object.respond_to?(:"__rr__#{@method_name}").should == true

        override_called = false
        method_name = @method_name
        (class << @object; self; end).class_eval do
          define_method :"__rr__#{method_name}" do
            override_called = true
          end
        end

        override_called.should == false
        @object == 1
        override_called.should == true
      end

      it "stores original method in __rr__original_method_name" do
        @double_injection.bind
        @object.respond_to?(:"__rr__original_#{@method_name}").should == true
        @object.method(:"__rr__original_#{@method_name}").should == @original_method
      end
    end
  end
end