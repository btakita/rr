require "spec/spec_helper"

module RR
  describe Space do
    it_should_behave_like "Swapped Space"

    describe ".method_missing" do
      it "proxies to a singleton instance of Space" do
        create_double_args = nil
        (class << @space; self; end).class_eval do
          define_method :double_injection do |*args|
            create_double_args = args
          end
        end

        Space.double_injection(:foo, :bar)
        create_double_args.should == [:foo, :bar]
      end
    end

    describe "#double_injection" do
      before do
        @space = Space.new
      end

      it "creates a new double_injection when existing object == but not === with the same method name" do
        object1 = []
        object2 = []
        (object1 === object2).should be_true
        object1.__id__.should_not == object2.__id__

        double1 = @space.double_injection(object1, :foobar)
        double2 = @space.double_injection(object2, :foobar)

        double1.should_not == double2
      end

      context "when double_injection does not exist" do
        before do
          @object = Object.new
          def @object.foobar(*args)
            :original_foobar
          end
          @method_name = :foobar
        end

        it "returns double_injection and adds double_injection to double_injection list when method_name is a symbol" do
          double_injection = @space.double_injection(@object, @method_name)
          @space.double_injection(@object, @method_name).should === double_injection
          double_injection.object.should === @object
          double_injection.method_name.should === @method_name
        end

        it "returns double_injection and adds double_injection to double_injection list when method_name is a string" do
          double_injection = @space.double_injection(@object, 'foobar')
          @space.double_injection(@object, @method_name).should === double_injection
          double_injection.object.should === @object
          double_injection.method_name.should === @method_name
        end

        it "overrides the method when passing a block" do
          double_injection = @space.double_injection(@object, @method_name)
          @object.methods.should include("__rr__#{@method_name}")
        end
      end

      context "when double_injection exists" do
        before do
          @object = Object.new
          def @object.foobar(*args)
            :original_foobar
          end
          @method_name = :foobar
        end

        it "returns the existing double_injection" do
          original_foobar_method = @object.method(:foobar)
          double_injection = @space.double_injection(@object, 'foobar')

          double_injection.object_has_original_method?.should be_true

          @space.double_injection(@object, 'foobar').should === double_injection

          double_injection.reset
          @object.foobar.should == :original_foobar
        end
      end
    end

    describe "#reset" do
      before do
        @space = Space.instance
        @object1 = Object.new
        @object2 = Object.new
        @method_name = :foobar
      end

      it "removes the ordered doubles" do
        double1 = @space.double_injection(@object1, :foobar1)
        double2 = @space.double_injection(@object1, :foobar2)

        double1 = Double.new(double1)
        double2 = Double.new(double2)

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
      before do
        @object1 = Object.new
        @object2 = Object.new
        @method_name = :foobar
      end

      it "resets the double_injection and removes it from the double_injections list" do
        double1 = @space.double_injection(@object1, @method_name)
        double1_reset_calls = 0
        (class << double1; self; end).class_eval do
          define_method(:reset) do ||
            double1_reset_calls += 1
          end
        end
        double2 = @space.double_injection(@object2, @method_name)
        double2_reset_calls = 0
        (class << double2; self; end).class_eval do
          define_method(:reset) do ||
            double2_reset_calls += 1
          end
        end

        @space.__send__(:reset_double_injections)
        double1_reset_calls.should == 1
        double2_reset_calls.should == 1
      end
    end
    
    describe "#register_ordered_double" do
      before(:each) do
        @object = Object.new
        @method_name = :foobar
        @double_injection = @space.double_injection(@object, @method_name)
      end

      it "adds the ordered double to the ordered_doubles collection" do
        double1 = Double.new(@double_injection)

        @space.ordered_doubles.should == []
        @space.register_ordered_double double1
        @space.ordered_doubles.should == [double1]

        double2 = Double.new(@double_injection)
        @space.register_ordered_double double2
        @space.ordered_doubles.should == [double1, double2]
      end
    end

    describe "#verify_doubles" do
      before do
        @object1 = Object.new
        @object2 = Object.new
        @method_name = :foobar
      end

      it "verifies and deletes the double_injections" do
        double1 = @space.double_injection(@object1, @method_name)
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
        double2 = @space.double_injection(@object2, @method_name)
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

    describe "#verify_double" do
      before do
        @object = Object.new
        @method_name = :foobar
      end

      it "verifies and deletes the double_injection" do
        double_injection = @space.double_injection(@object, @method_name)
        @space.double_injections[@object][@method_name].should === double_injection
        @object.methods.should include("__rr__#{@method_name}")

        verify_calls = 0
        (class << double_injection; self; end).class_eval do
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
        (class << double_injection; self; end).class_eval do
          define_method(:verify) do ||
            verify_called = true
            raise "An Error"
          end
        end
        lambda {@space.verify_double(@object, @method_name)}.should raise_error
        verify_called.should be_true

        @space.double_injections[@object][@method_name].should be_nil
        @object.methods.should_not include("__rr__#{@method_name}")
      end
    end

    describe "#verify_ordered_double" do
      before do
        @object = Object.new
        @method_name = :foobar
        @double_injection = @space.double_injection(@object, @method_name)
      end

      class << self
        define_method "#verify_ordered_double" do
          it "raises an error when Double is NonTerminal" do
            double = Double.new(@double_injection)
            @space.register_ordered_double(double)

            double.any_number_of_times
            double.should_not be_terminal

            lambda do
              @space.verify_ordered_double(double)
            end.should raise_error(
            Errors::DoubleOrderError,
            "Ordered Doubles cannot have a NonTerminal TimesCalledExpectation"
            )
          end
        end
      end

      context "when the passed in double is at the front of the queue" do
        send "#verify_ordered_double"
        it "keeps the double when times called is not verified" do
          double = Double.new(@double_injection)
          @space.register_ordered_double(double)

          double.twice
          double.should be_attempt

          @space.verify_ordered_double(double)
          @space.ordered_doubles.should include(double)
        end

        it "removes the double when times called expectation should no longer be attempted" do
          double = Double.new(@double_injection)
          @space.register_ordered_double(double)

          double.with(1).once
          @object.foobar(1)
          double.should_not be_attempt

          @space.verify_ordered_double(double)
          @space.ordered_doubles.should_not include(double)
        end
      end

      context "when the passed in double is not at the front of the queue" do
        send "#verify_ordered_double"
        it "raises error" do
          first_double = double
          second_double = double

          lambda do
            @space.verify_ordered_double(second_double)
          end.should raise_error(
            Errors::DoubleOrderError,
            "foobar() called out of order in list\n" <<
            "- foobar()\n" <<
            "- foobar()"
          )
        end

        def double
          double = Double.new(@double_injection).once
          @space.register_ordered_double(double.double)
          double.double
        end
      end
    end
  end

end
