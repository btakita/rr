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

      it "removes the ordered scenarios" do
        double1 = @space.double_insertion(@object1, :foobar1)
        double2 = @space.double_insertion(@object1, :foobar2)

        scenario1 = @space.scenario(double1)
        scenario2 = @space.scenario(double2)

        scenario1.ordered
        scenario2.ordered

        @space.ordered_scenarios.should_not be_empty

        @space.reset
        @space.ordered_scenarios.should be_empty
      end

      it "resets all double_insertions" do
        double1 = @space.double_insertion(@object1, @method_name)
        double1_reset_calls = 0
        (
        class << double1;
          self;
        end).class_eval do
          define_method(:reset) do ||
            double1_reset_calls += 1
          end
        end
        double2 = @space.double_insertion(@object2, @method_name)
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

      it "resets the double_insertions" do
        double_insertion = @space.double_insertion(@object, @method_name)
        @space.double_insertions[@object][@method_name].should === double_insertion
        @object.methods.should include("__rr__#{@method_name}")

        @space.reset_double(@object, @method_name)
        @space.double_insertions[@object][@method_name].should be_nil
        @object.methods.should_not include("__rr__#{@method_name}")
      end

      it "removes the object from the double_insertions map when it has no double_insertions" do
        double1 = @space.double_insertion(@object, :foobar1)
        double2 = @space.double_insertion(@object, :foobar2)

        @space.double_insertions.include?(@object).should == true
        @space.double_insertions[@object][:foobar1].should_not be_nil
        @space.double_insertions[@object][:foobar2].should_not be_nil

        @space.reset_double(@object, :foobar1)
        @space.double_insertions.include?(@object).should == true
        @space.double_insertions[@object][:foobar1].should be_nil
        @space.double_insertions[@object][:foobar2].should_not be_nil

        @space.reset_double(@object, :foobar2)
        @space.double_insertions.include?(@object).should == false
      end
    end

    describe "#reset_double_insertions" do
      it_should_behave_like "RR::Space"

      before do
        @space = Space.new
        @object1 = Object.new
        @object2 = Object.new
        @method_name = :foobar
      end

      it "resets the double_insertion and removes it from the double_insertions list" do
        double1 = @space.double_insertion(@object1, @method_name)
        double1_reset_calls = 0
        (
        class << double1;
          self;
        end).class_eval do
          define_method(:reset) do ||
            double1_reset_calls += 1
          end
        end
        double2 = @space.double_insertion(@object2, @method_name)
        double2_reset_calls = 0
        (
        class << double2;
          self;
        end).class_eval do
          define_method(:reset) do ||
            double2_reset_calls += 1
          end
        end

        @space.send(:reset_double_insertions)
        double1_reset_calls.should == 1
        double2_reset_calls.should == 1
      end
    end
  end
end
