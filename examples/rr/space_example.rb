dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

describe RR::Space, " class" do
  it "proxies to a singleton instance of RR::Space" do
    space = RR::Space.new
    (class << RR::Space; self; end).class_eval do
      define_method :instance do
        space
      end
    end

    create_double_args = nil
    (class << space; self; end).class_eval do
      define_method :create_double do |*args|
        create_double_args = args
      end
    end

    RR::Space.create_double(:foo, :bar)
    create_double_args.should == [:foo, :bar]
  end
end

describe RR::Space, "#create_double" do
  before do
    @space = RR::Space.new
    @object = Object.new
    @method_name = :foobar
  end

  it "returns double and adds double to double list when method_name is a symbol" do
    double = @space.create_double(@object, @method_name)
    @space.doubles[@object][@method_name].should === double
    double.space.should === @space
    double.object.should === @object
    double.method_name.should === @method_name
  end

  it "returns double and adds double to double list when method_name is a string" do
    double = @space.create_double(@object, 'foobar')
    @space.doubles[@object][@method_name].should === double
    double.space.should === @space
    double.object.should === @object
    double.method_name.should === @method_name
  end

  it "overrides existing doubles" do
    double = @space.create_double(@object, 'foobar') {}
    double.add_expectation(RR::Expectations::TimesCalledExpectation.new(1))
    @object.foobar
    
    double2 = @space.create_double(@object, 'foobar') {}
    double2.add_expectation(RR::Expectations::TimesCalledExpectation.new(1))
    @object.foobar
  end

  it "overrides the method when passing a block" do
    double = @space.create_double(@object, @method_name) {:foobar}
    @object.methods.should include("__rr__#{@method_name}__rr__")
  end
end

describe RR::Space, "#verify_double" do
  it "verifies and deletes the double" do
    @space = RR::Space.new
    @object = Object.new
    @method_name = :foobar

    double = @space.create_double(@object, @method_name) {}
    @space.doubles[@object][@method_name].should === double
    @object.methods.should include("__rr__#{@method_name}__rr__")

    double.should_receive(:verify)
    @space.verify_double(@object, @method_name)

    @space.doubles[@object][@method_name].should be_nil
    @object.methods.should_not include("__rr__#{@method_name}__rr__")
  end
end

describe RR::Space, "#reset_double" do
  it "resets the double and removes it from the doubles list" do
    @space = RR::Space.new
    @object = Object.new
    @method_name = :foobar

    double = @space.create_double(@object, @method_name) {}
    @space.doubles[@object][@method_name].should === double
    @object.methods.should include("__rr__#{@method_name}__rr__")

    @space.reset_double(@object, @method_name)
    @space.doubles[@object][@method_name].should be_nil
    @object.methods.should_not include("__rr__#{@method_name}__rr__")
  end
end
