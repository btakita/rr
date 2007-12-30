require "spec/spec_helper"

module RR
  describe DoubleInsertion, "#bind with an existing method" do
    before do
      @space = Space.new
      @object = Object.new
      @method_name = :foobar
      def @object.foobar;
        :original_foobar;
      end
      @original_method = @object.method(:foobar)
      @object.methods.should include(@method_name.to_s)
      @double_insertion = DoubleInsertion.new(@space, @object, @method_name)
    end

    it "overrides the original method with the double_insertion's dispatching methods" do
      @object.respond_to?(:__rr__foobar).should == false
      @double_insertion.bind
      @object.respond_to?(:__rr__foobar).should == true

      rr_foobar_called = false
      (
      class << @object;
        self;
      end).class_eval do
        define_method :__rr__foobar do
          rr_foobar_called = true
        end
      end

      rr_foobar_called.should == false
      @object.foobar
      rr_foobar_called.should == true
    end

    it "stores original method in __rr__original_method_name" do
      @double_insertion.bind
      @object.respond_to?(:__rr__original_foobar).should == true
      @object.method(:__rr__original_foobar).should == @original_method
    end
  end

  describe DoubleInsertion, "#bind without an existing method" do
    before do
      @space = Space.new
      @object = Object.new
      @method_name = :foobar
      @object.methods.should_not include(@method_name.to_s)
      @double_insertion = DoubleInsertion.new(@space, @object, @method_name)
    end

    it "overrides the original method with the double_insertion's dispatching methods" do
      @object.respond_to?(:__rr__foobar).should == false
      @double_insertion.bind
      @object.respond_to?(:__rr__foobar).should == true

      rr_foobar_called = false
      (
      class << @object;
        self;
      end).class_eval do
        define_method :__rr__foobar do
          rr_foobar_called = true
        end
      end

      rr_foobar_called.should == false
      @object.foobar
      rr_foobar_called.should == true
    end

    it "stores original method in __rr__original_method_name" do
      @double_insertion.bind
      @object.respond_to?(:__rr__original_foobar).should == false
    end
  end
end