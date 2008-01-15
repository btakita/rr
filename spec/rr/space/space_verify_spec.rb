require "spec/spec_helper"

module RR
  describe Space, "#verify_ordered_double", :shared => true do
    before do
      @space = Space.new
      @object = Object.new
      @method_name = :foobar
      @double_injection = @space.double_injection(@object, @method_name)
    end

    it "raises an error when Double is NonTerminal" do
      double = @space.double(@double_injection)
      @space.register_ordered_double(double)

      double.any_number_of_times
      double.should_not be_terminal

      proc do
        @space.verify_ordered_double(double)
      end.should raise_error(
      Errors::DoubleOrderError,
      "Ordered Doubles cannot have a NonTerminal TimesCalledExpectation"
      )
    end
  end

  describe Space do
    it_should_behave_like "RR::Space"

    describe "#verify_doubles" do
      before do
        @space = Space.new
        @object1 = Object.new
        @object2 = Object.new
        @method_name = :foobar
      end

      it "verifies and deletes the double_injections" do
        double1 = @space.double_injection(@object1, @method_name)
        double1_verify_calls = 0
        double1_reset_calls = 0
        (
        class << double1;
          self;
        end).class_eval do
          define_method(:verify) do ||
            double1_verify_calls += 1
          end
          define_method(:reset) do ||
            double1_reset_calls += 1
          end
        end
        double2 = @space.double_injection(@object2, @method_name)
        double2_verify_calls = 0
        double2_reset_calls = 0
        (
        class << double2;
          self;
        end).class_eval do
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

    describe "#verify_double" do
      it_should_behave_like "RR::Space"

      before do
        @space = Space.new
        @object = Object.new
        @method_name = :foobar
      end

      it "verifies and deletes the double_injection" do
        double_injection = @space.double_injection(@object, @method_name)
        @space.double_injections[@object][@method_name].should === double_injection
        @object.methods.should include("__rr__#{@method_name}")

        verify_calls = 0
        (
        class << double_injection;
          self;
        end).class_eval do
          define_method(:verify) do ||
            verify_calls += 1
          end
        end
        @space.verify_double(@object, @method_name)
        verify_calls.should == 1

        @space.double_injections[@object][@method_name].should be_nil
        @object.methods.should_not include("__rr__#{@method_name}")
      end

      it "deletes the double_injection when verifying the double_injection raises an error" do
        double_injection = @space.double_injection(@object, @method_name)
        @space.double_injections[@object][@method_name].should === double_injection
        @object.methods.should include("__rr__#{@method_name}")

        verify_called = true
        (
        class << double_injection;
          self;
        end).class_eval do
          define_method(:verify) do ||
            verify_called = true
            raise "An Error"
          end
        end
        proc {@space.verify_double(@object, @method_name)}.should raise_error
        verify_called.should be_true

        @space.double_injections[@object][@method_name].should be_nil
        @object.methods.should_not include("__rr__#{@method_name}")
      end
    end

    describe "#verify_ordered_double where the passed in double is at the front of the queue" do
      it_should_behave_like "RR::Space#verify_ordered_double"

      it "keeps the double when times called is not verified" do
        double = @space.double(@double_injection)
        @space.register_ordered_double(double)

        double.twice
        double.should be_attempt

        @space.verify_ordered_double(double)
        @space.ordered_doubles.should include(double)
      end

      it "removes the double when times called expectation should no longer be attempted" do
        double = @space.double(@double_injection)
        @space.register_ordered_double(double)

        double.with(1).once
        @object.foobar(1)
        double.should_not be_attempt

        @space.verify_ordered_double(double)
        @space.ordered_doubles.should_not include(double)
      end
    end

    describe "#verify_ordered_double where the passed in double is not at the front of the queue" do
      it_should_behave_like "RR::Space#verify_ordered_double"

      it "raises error" do
        first_double = double
        second_double = double

        proc do
          @space.verify_ordered_double(second_double)
        end.should raise_error(
        Errors::DoubleOrderError,
        "foobar() called out of order in list\n" <<
        "- foobar()\n" <<
        "- foobar()"
        )
      end

      def double
        double_definition = @space.double(@double_injection).once
        @space.register_ordered_double(double_definition.double)
        double_definition.double
      end
    end
  end
end