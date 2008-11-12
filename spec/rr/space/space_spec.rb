require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  describe Space do
    it_should_behave_like "Swapped Space"
    attr_reader :space, :subject, :method_name, :double_injection

    before do
      @subject = Object.new
    end

    describe ".method_missing" do
      it "proxies to a singleton instance of Space" do
        create_double_args = nil
        (class << space; self; end).class_eval do
          define_method :double_injection do |*args|
            create_double_args = args
          end
        end

        space.double_injection(:foo, :bar)
        create_double_args.should == [:foo, :bar]
      end
    end
    
    describe "#record_call" do
      it "should add a call to the list"  do
        object = Object.new
        block = lambda {}
        space.record_call(object,:to_s,[], block)
        space.recorded_calls.should == RR::RecordedCalls.new([[object,:to_s,[], block]])
      end
    end
    
    describe "#double_injection" do
      context "when existing subject == but not === with the same method name" do
        it "creates a new DoubleInjection" do
          subject_1 = []
          subject_2 = []
          (subject_1 === subject_2).should be_true
          subject_1.__id__.should_not == subject_2.__id__

          double_1 = space.double_injection(subject_1, :foobar)
          double_2 = space.double_injection(subject_2, :foobar)

          double_1.should_not == double_2
        end
      end

      context "when double_injection does not exist" do
        before do
          def subject.foobar(*args)
            :original_foobar
          end
          @method_name = :foobar
        end

        context "when method_name is a symbol" do
          it "returns double_injection and adds double_injection to double_injection list" do
            @double_injection = space.double_injection(subject, method_name)
            space.double_injection(subject, method_name).should === double_injection
            double_injection.subject.should === subject
            double_injection.method_name.should === method_name
          end
        end

        context "when method_name is a string" do
          it "returns double_injection and adds double_injection to double_injection list" do
            @double_injection = space.double_injection(subject, 'foobar')
            space.double_injection(subject, method_name).should === double_injection
            double_injection.subject.should === subject
            double_injection.method_name.should === method_name
          end
        end

        it "overrides the method when passing a block" do
          @double_injection = space.double_injection(subject, method_name)
          subject.methods.should include("__rr__#{method_name}")
        end
      end

      context "when double_injection exists" do
        before do
          def subject.foobar(*args)
            :original_foobar
          end
          @method_name = :foobar
        end

        it "returns the existing double_injection" do
          original_foobar_method = subject.method(:foobar)
          @double_injection = space.double_injection(subject, 'foobar')

          double_injection.object_has_original_method?.should be_true

          space.double_injection(subject, 'foobar').should === double_injection

          double_injection.reset
          subject.foobar.should == :original_foobar
        end
      end
    end

    describe "#reset" do
      attr_reader :subject_1, :subject_2
      before do
        @subject_1 = Object.new
        @subject_2 = Object.new
        @method_name = :foobar
      end
      
      it "should clear the #recorded_calls" do
        object = Object.new
        space.record_call(object,:to_s,[], nil)
        
        space.reset
        space.recorded_calls.should == RR::RecordedCalls.new([])
      end

      it "removes the ordered doubles" do
        double_1 = new_double(
          space.double_injection(subject_1, :foobar1),
          RR::DoubleDefinitions::DoubleDefinition.new(creator = Object.new, subject_1)
        )
        double_2 = new_double(
          space.double_injection(subject_2, :foobar2),
          RR::DoubleDefinitions::DoubleDefinition.new(creator = Object.new, subject_2)
        )
        double_1.definition.ordered
        double_2.definition.ordered

        space.ordered_doubles.should_not be_empty

        space.reset
        space.ordered_doubles.should be_empty
      end

      it "resets all double_injections" do
        double_1 = space.double_injection(subject_1, method_name)
        double_1_reset_call_count = 0
        (
        class << double_1;
          self;
        end).class_eval do
          define_method(:reset) do ||
            double_1_reset_call_count += 1
          end
        end
        double_2 = space.double_injection(subject_2, method_name)
        double_2_reset_call_count = 0
        (
        class << double_2;
          self;
        end).class_eval do
          define_method(:reset) do ||
            double_2_reset_call_count += 1
          end
        end

        space.reset
        double_1_reset_call_count.should == 1
        double_2_reset_call_count.should == 1
      end
    end

    describe "#reset_double" do
      before do
        @method_name = :foobar
      end

      it "resets the double_injections" do
        @double_injection = space.double_injection(subject, method_name)
        space.double_injections[subject][method_name].should === double_injection
        subject.methods.should include("__rr__#{method_name}")

        space.reset_double(subject, method_name)
        space.double_injections[subject][method_name].should be_nil
        subject.methods.should_not include("__rr__#{method_name}")
      end

      context "when it has no double_injections" do
        it "removes the subject from the double_injections map" do
          double_1 = space.double_injection(subject, :foobar1)
          double_2 = space.double_injection(subject, :foobar2)

          space.double_injections.include?(subject).should == true
          space.double_injections[subject][:foobar1].should_not be_nil
          space.double_injections[subject][:foobar2].should_not be_nil

          space.reset_double(subject, :foobar1)
          space.double_injections.include?(subject).should == true
          space.double_injections[subject][:foobar1].should be_nil
          space.double_injections[subject][:foobar2].should_not be_nil

          space.reset_double(subject, :foobar2)
          space.double_injections.include?(subject).should == false
        end
      end
    end

    describe "#reset_double_injections" do
      attr_reader :subject_1, :subject_2
      before do
        @subject_1 = Object.new
        @subject_2 = Object.new
        @method_name = :foobar
      end

      it "resets the double_injection and removes it from the double_injections list" do
        double_injection_1 = space.double_injection(subject_1, method_name)
        double_1_reset_call_count = 0
        (class << double_injection_1; self; end).class_eval do
          define_method(:reset) do
            double_1_reset_call_count += 1
          end
        end
        double_injection_2 = space.double_injection(subject_2, method_name)
        double_2_reset_call_count = 0
        (class << double_injection_2; self; end).class_eval do
          define_method(:reset) do
            double_2_reset_call_count += 1
          end
        end

        space.__send__(:reset_double_injections)
        double_1_reset_call_count.should == 1
        double_2_reset_call_count.should == 1
      end
    end

    describe "#register_ordered_double" do
      before(:each) do
        @method_name = :foobar
        @double_injection = space.double_injection(subject, method_name)
      end

      it "adds the ordered double to the ordered_doubles collection" do
        double_1 = new_double

        space.ordered_doubles.should == []
        space.register_ordered_double double_1
        space.ordered_doubles.should == [double_1]

        double_2 = new_double
        space.register_ordered_double double_2
        space.ordered_doubles.should == [double_1, double_2]
      end
    end

    describe "#verify_doubles" do
      attr_reader :subject_1, :subject_2, :subject3, :double_1, :double_2, :double3
      before do
        @subject_1 = Object.new
        @subject_2 = Object.new
        @subject3 = Object.new
        @method_name = :foobar
        @double_1 = space.double_injection(subject_1, method_name)
        @double_2 = space.double_injection(subject_2, method_name)
        @double3 = space.double_injection(subject3, method_name)
      end

      context "when passed no arguments" do
        it "verifies and deletes the double_injections" do
          double_1_verify_call_count = 0
          double_1_reset_call_count = 0
          (class << double_1; self; end).class_eval do
            define_method(:verify) do
              double_1_verify_call_count += 1
            end
            define_method(:reset) do
              double_1_reset_call_count += 1
            end
          end

          double_2_verify_call_count = 0
          double_2_reset_call_count = 0
          (class << double_2; self; end).class_eval do
            define_method(:verify) do
              double_2_verify_call_count += 1
            end
            define_method(:reset) do
              double_2_reset_call_count += 1
            end
          end

          space.verify_doubles
          double_1_verify_call_count.should == 1
          double_2_verify_call_count.should == 1
          double_1_reset_call_count.should == 1
          double_1_reset_call_count.should == 1
        end
      end

      context "when passed an Object that has at least one DoubleInjection" do
        it "verifies all Doubles injected into the Object" do
          double_1_verify_call_count = 0
          double_1_reset_call_count = 0
          (class << double_1; self; end).class_eval do
            define_method(:verify) do
              double_1_verify_call_count += 1
            end
            define_method(:reset) do
              double_1_reset_call_count += 1
            end
          end

          double_2_verify_call_count = 0
          double_2_reset_call_count = 0
          (class << double_2; self; end).class_eval do
            define_method(:verify) do
              double_2_verify_call_count += 1
            end
            define_method(:reset) do
              double_2_reset_call_count += 1
            end
          end

          space.verify_doubles(subject_1)

          double_1_verify_call_count.should == 1
          double_1_reset_call_count.should == 1
          double_2_verify_call_count.should == 0
          double_2_reset_call_count.should == 0
        end
      end

      context "when passed multiple Objects with at least one DoubleInjection" do
        it "verifies the Doubles injected into all of the Objects" do
          double_1_verify_call_count = 0
          double_1_reset_call_count = 0
          (class << double_1; self; end).class_eval do
            define_method(:verify) do
              double_1_verify_call_count += 1
            end
            define_method(:reset) do
              double_1_reset_call_count += 1
            end
          end

          double_2_verify_call_count = 0
          double_2_reset_call_count = 0
          (class << double_2; self; end).class_eval do
            define_method(:verify) do
              double_2_verify_call_count += 1
            end
            define_method(:reset) do
              double_2_reset_call_count += 1
            end
          end

          double3_verify_call_count = 0
          double3_reset_call_count = 0
          (class << double3; self; end).class_eval do
            define_method(:verify) do
              double3_verify_call_count += 1
            end
            define_method(:reset) do
              double3_reset_call_count += 1
            end
          end

          space.verify_doubles(subject_1, subject_2)

          double_1_verify_call_count.should == 1
          double_1_reset_call_count.should == 1
          double_2_verify_call_count.should == 1
          double_2_reset_call_count.should == 1
          double3_verify_call_count.should == 0
          double3_reset_call_count.should == 0
        end
      end

      context "when passed an subject that does not have a DoubleInjection" do
        it "does not raise an error" do
          double_1_verify_call_count = 0
          double_1_reset_call_count = 0
          (class << double_1; self; end).class_eval do
            define_method(:verify) do
              double_1_verify_call_count += 1
            end
            define_method(:reset) do
              double_1_reset_call_count += 1
            end
          end

          double_2_verify_call_count = 0
          double_2_reset_call_count = 0
          (class << double_2; self; end).class_eval do
            define_method(:verify) do
              double_2_verify_call_count += 1
            end
            define_method(:reset) do
              double_2_reset_call_count += 1
            end
          end

          double3_verify_call_count = 0
          double3_reset_call_count = 0
          (class << double3; self; end).class_eval do
            define_method(:verify) do
              double3_verify_call_count += 1
            end
            define_method(:reset) do
              double3_reset_call_count += 1
            end
          end

          no_double_injection_object = Object.new
          space.verify_doubles(no_double_injection_object)

          double_1_verify_call_count.should == 0
          double_1_reset_call_count.should == 0
          double_2_verify_call_count.should == 0
          double_2_reset_call_count.should == 0
          double3_verify_call_count.should == 0
          double3_reset_call_count.should == 0
        end
      end
    end

    describe "#verify_double" do
      before do
        @method_name = :foobar
      end

      it "verifies and deletes the double_injection" do
        @double_injection = space.double_injection(subject, method_name)
        space.double_injections[subject][method_name].should === double_injection
        subject.methods.should include("__rr__#{method_name}")

        verify_call_count = 0
        (class << double_injection; self; end).class_eval do
          define_method(:verify) do
            verify_call_count += 1
          end
        end
        space.verify_double(subject, method_name)
        verify_call_count.should == 1

        space.double_injections[subject][method_name].should be_nil
        subject.methods.should_not include("__rr__#{method_name}")
      end

      context "when verifying the double_injection raises an error" do
        it "deletes the double_injection" do
          @double_injection = space.double_injection(subject, method_name)
          space.double_injections[subject][method_name].should === double_injection
          subject.methods.should include("__rr__#{method_name}")

          verify_called = true
          (class << double_injection; self; end).class_eval do
            define_method(:verify) do
              verify_called = true
              raise "An Error"
            end
          end
          lambda {space.verify_double(subject, method_name)}.should raise_error
          verify_called.should be_true

          space.double_injections[subject][method_name].should be_nil
          subject.methods.should_not include("__rr__#{method_name}")
        end
      end
    end

    describe "#verify_ordered_double" do
      before do
        @method_name = :foobar
        @double_injection = space.double_injection(subject, method_name)
      end

      macro "#verify_ordered_double" do
        it "raises an error when Double is NonTerminal" do
          double = new_double
          space.register_ordered_double(double)

          double.definition.any_number_of_times
          double.should_not be_terminal

          lambda do
            space.verify_ordered_double(double)
          end.should raise_error(
          Errors::DoubleOrderError,
          "Ordered Doubles cannot have a NonTerminal TimesCalledExpectation"
          )
        end
      end

      context "when the passed in double is at the front of the queue" do
        send "#verify_ordered_double"
        it "keeps the double when times called is not verified" do
          double = new_double
          space.register_ordered_double(double)

          double.definition.twice
          double.should be_attempt

          space.verify_ordered_double(double)
          space.ordered_doubles.should include(double)
        end

        context "when Double#attempt? is false" do
          it "removes the double" do
            double = new_double
            space.register_ordered_double(double)

            double.definition.with(1).once
            subject.foobar(1)
            double.should_not be_attempt

            space.verify_ordered_double(double)
            space.ordered_doubles.should_not include(double)
          end
        end
      end

      context "when the passed in double is not at the front of the queue" do
        send "#verify_ordered_double"
        it "raises error" do
          first_double = new_double
          second_double = new_double

          lambda do
            space.verify_ordered_double(second_double)
          end.should raise_error(
            Errors::DoubleOrderError,
            "foobar() called out of order in list\n" <<
            "- foobar()\n" <<
            "- foobar()"
          )
        end

        def new_double
          double = super
          double.definition.once
          space.register_ordered_double(double)
          double
        end
      end
    end
  end
end
