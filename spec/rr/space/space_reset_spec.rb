require "spec/spec_helper"

module RR
  describe Space do
    it_should_behave_like "RR::Space"
    describe "#reset" do
      before do
        @space = Space.new
        @object1 = Object.new
        @object2 = Object.new
        @method_name = :foobar
      end

      it "removes the ordered doubles" do
        double1 = @space.double_injection(@object1, :foobar1)
        double2 = @space.double_injection(@object1, :foobar2)

        double1 = @space.double(double1)
        double2 = @space.double(double2)

        double1.ordered
        double2.ordered

        @space.ordered_doubles.should_not be_empty

        @space.reset
        @space.ordered_doubles.should be_empty
      end

      it "resets all double_injections" do
        double1 = @space.double_injection(@object1, @method_name)
        double1_reset_calls = 0
        (
        class << double1;
          self;
        end).class_eval do
          define_method(:reset) do ||
            double1_reset_calls += 1
          end
        end
        double2 = @space.double_injection(@object2, @method_name)
        double2_reset_calls = 0
        (
        class << double2;
          self;
        end).class_eval do
          define_method(:reset) do ||
            double2_reset_calls += 1
          end
        end

        @space.reset
        double1_reset_calls.should == 1
        double2_reset_calls.should == 1
      end
    end

    describe "#reset_double" do
      before do
        @space = Space.new
        @object = Object.new
        @method_name = :foobar
      end

      it "resets the double_injections" do
        double_injection = @space.double_injection(@object, @method_name)
        @space.double_injections[@object][@method_name].should === double_injection
        @object.methods.should include("__rr__#{@method_name}")

        @space.reset_double(@object, @method_name)
        @space.double_injections[@object][@method_name].should be_nil
        @object.methods.should_not include("__rr__#{@method_name}")
      end

      it "removes the object from the double_injections map when it has no double_injections" do
        double1 = @space.double_injection(@object, :foobar1)
        double2 = @space.double_injection(@object, :foobar2)

        @space.double_injections.include?(@object).should == true
        @space.double_injections[@object][:foobar1].should_not be_nil
        @space.double_injections[@object][:foobar2].should_not be_nil

        @space.reset_double(@object, :foobar1)
        @space.double_injections.include?(@object).should == true
        @space.double_injections[@object][:foobar1].should be_nil
        @space.double_injections[@object][:foobar2].should_not be_nil

        @space.reset_double(@object, :foobar2)
        @space.double_injections.include?(@object).should == false
      end
    end

    describe "#reset_double_injections" do
      it_should_behave_like "RR::Space"

      before do
        @space = Space.new
        @object1 = Object.new
        @object2 = Object.new
        @method_name = :foobar
      end

      it "resets the double_injection and removes it from the double_injections list" do
        double1 = @space.double_injection(@object1, @method_name)
        double1_reset_calls = 0
        (
        class << double1;
          self;
        end).class_eval do
          define_method(:reset) do ||
            double1_reset_calls += 1
          end
        end
        double2 = @space.double_injection(@object2, @method_name)
        double2_reset_calls = 0
        (
        class << double2;
          self;
        end).class_eval do
          define_method(:reset) do ||
            double2_reset_calls += 1
          end
        end

        @space.__send__(:reset_double_injections)
        double1_reset_calls.should == 1
        double2_reset_calls.should == 1
      end
    end
  end
end
