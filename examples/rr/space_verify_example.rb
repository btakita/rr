dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
describe Space, "#verify_doubles" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object1 = Object.new
    @object2 = Object.new
    @method_name = :foobar
  end

  it "verifies and deletes the doubles" do
    double1 = @space.create_double(@object1, @method_name)
    double1_verify_calls = 0
    double1_reset_calls = 0
    (class << double1; self; end).class_eval do
      define_method(:verify) do ||
        double1_verify_calls += 1
      end
      define_method(:reset) do ||
        double1_reset_calls += 1
      end
    end
    double2 = @space.create_double(@object2, @method_name)
    double2_verify_calls = 0
    double2_reset_calls = 0
    (class << double2; self; end).class_eval do
      define_method(:verify) do ||
        double2_verify_calls += 1
      end
      define_method(:reset) do ||
        double2_reset_calls += 1
      end
    end

    @space.verify_doubles
    double1_verify_calls.should == 1
    double2_verify_calls.should == 1
    double1_reset_calls.should == 1
    double1_reset_calls.should == 1
  end
end

describe Space, "#verify_double" do
  it_should_behave_like "RR::Space"

  before do
    @space = Space.new
    @object = Object.new
    @method_name = :foobar
  end

  it "verifies and deletes the double" do
    double = @space.create_double(@object, @method_name)
    @space.doubles[@object][@method_name].should === double
    @object.methods.should include("__rr__#{@method_name}__rr__")

    verify_calls = 0
    (class << double; self; end).class_eval do
      define_method(:verify) do ||
        verify_calls += 1
      end
    end
    @space.verify_double(@object, @method_name)
    verify_calls.should == 1

    @space.doubles[@object][@method_name].should be_nil
    @object.methods.should_not include("__rr__#{@method_name}__rr__")
  end

  it "deletes the double when verifying the double raises an error" do
    double = @space.create_double(@object, @method_name)
    @space.doubles[@object][@method_name].should === double
    @object.methods.should include("__rr__#{@method_name}__rr__")

    verify_called = true
    (class << double; self; end).class_eval do
      define_method(:verify) do ||
        verify_called = true
        raise "An Error"
      end
    end
    proc {@space.verify_double(@object, @method_name)}.should raise_error
    verify_called.should be_true

    @space.doubles[@object][@method_name].should be_nil
    @object.methods.should_not include("__rr__#{@method_name}__rr__")
  end
end
end