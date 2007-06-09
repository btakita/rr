dir = File.dirname(__FILE__)
require "#{dir}/../example_helper"

module RR
  describe Space, :shared => true do
    after(:each) do
      RR::Space.instance.verify_doubles
    end
  end

  describe Space, " class" do
    it_should_behave_like "RR::Space"

    before(:each) do
      @original_space = RR::Space.instance
      @space = RR::Space.new
      RR::Space.instance = @space
    end

    after(:each) do
      RR::Space.instance = @original_space
    end

    it "proxies to a singleton instance of RR::Space" do
      create_double_args = nil
      (class << @space; self; end).class_eval do
        define_method :create_double do |*args|
          create_double_args = args
        end
      end

      RR::Space.create_double(:foo, :bar)
      create_double_args.should == [:foo, :bar]
    end
  end

  describe Space, "#create_double" do
    it_should_behave_like "RR::Space"

    before do
      @space = RR::Space.new
      @object = Object.new
      def @object.foobar(*args)
        :original_foobar
      end
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

    it "when existing double, resets the original method and overrides existing double" do
      original_foobar_method = @object.method(:foobar)
      double = @space.create_double(@object, 'foobar') {}
      double.add_expectation(RR::Expectations::TimesCalledExpectation.new(1))
      @object.foobar

      double.original_method.should == original_foobar_method

      double2 = @space.create_double(@object, 'foobar') {}
      double2.add_expectation(RR::Expectations::TimesCalledExpectation.new(1))
      @object.foobar

      double2.reset
      @object.foobar.should == :original_foobar
    end

    it "overrides the method when passing a block" do
      double = @space.create_double(@object, @method_name) {:foobar}
      @object.methods.should include("__rr__#{@method_name}__rr__")
    end
  end

  describe Space, "#verify_doubles" do
    it_should_behave_like "RR::Space"

    before do
      @space = RR::Space.new
      @object1 = Object.new
      @object2 = Object.new
      @method_name = :foobar
    end

    it "verifies and deletes the doubles" do
      double1 = @space.create_double(@object1, @method_name) {}
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
      double2 = @space.create_double(@object2, @method_name) {}
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
      @space = RR::Space.new
      @object = Object.new
      @method_name = :foobar
    end

    it "verifies and deletes the double" do
      double = @space.create_double(@object, @method_name) {}
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
  end

  describe Space, "#reset_double" do
    it_should_behave_like "RR::Space"

    before do
      @space = RR::Space.new
      @object = Object.new
      @method_name = :foobar
    end

    it "resets the doubles" do
      double = @space.create_double(@object, @method_name) {}
      @space.doubles[@object][@method_name].should === double
      @object.methods.should include("__rr__#{@method_name}__rr__")

      @space.reset_double(@object, @method_name)
      @space.doubles[@object][@method_name].should be_nil
      @object.methods.should_not include("__rr__#{@method_name}__rr__")
    end

    it "removes the object from the doubles map when it has no doubles" do
      double1 = @space.create_double(@object, :foobar1) {}
      double2 = @space.create_double(@object, :foobar2) {}

      @space.doubles.include?(@object).should == true
      @space.doubles[@object][:foobar1].should_not be_nil
      @space.doubles[@object][:foobar2].should_not be_nil

      @space.reset_double(@object, :foobar1)
      @space.doubles.include?(@object).should == true
      @space.doubles[@object][:foobar1].should be_nil
      @space.doubles[@object][:foobar2].should_not be_nil

      @space.reset_double(@object, :foobar2)
      @space.doubles.include?(@object).should == false
    end
  end

  describe Space, "#reset_doubles" do
    it_should_behave_like "RR::Space"

    before do
      @space = RR::Space.new
      @object1 = Object.new
      @object2 = Object.new
      @method_name = :foobar
    end

    it "resets the double and removes it from the doubles list" do
      double1 = @space.create_double(@object1, @method_name) {}
      double1_reset_calls = 0
      (class << double1; self; end).class_eval do
        define_method(:reset) do ||
          double1_reset_calls += 1
        end
      end
      double2 = @space.create_double(@object2, @method_name) {}
      double2_reset_calls = 0
      (class << double2; self; end).class_eval do
        define_method(:reset) do ||
          double2_reset_calls += 1
        end
      end

      @space.reset_doubles
      double1_reset_calls.should == 1
      double1_reset_calls.should == 1
    end
  end
end
