require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  describe Space do
    it_should_behave_like "Swapped Space"
    attr_reader :subject, :method_name, :double_injection

    before do
      @subject = Object.new
    end

    describe "#record_call" do
      it "should add a call to the list" do
        object = Object.new
        block = lambda {}
        space.record_call(object, :to_s, [], block)
        space.recorded_calls.should == RR::RecordedCalls.new([[object, :to_s, [], block]])
      end
    end

    describe "#double_injection" do
      context "when existing subject == but not === with the same method name" do
        it "creates a new DoubleInjection" do
          subject_1 = []
          subject_2 = []
          (subject_1 === subject_2).should be_true
          subject_1.__id__.should_not == subject_2.__id__

          injection_1 = Injections::DoubleInjection.find_or_create_by_subject(subject_1, :foobar)
          injection_2 = Injections::DoubleInjection.find_or_create_by_subject(subject_2, :foobar)

          injection_1.should_not == injection_2
        end
      end

      context "when a DoubleInjection is not registered for the subject and method_name" do
        before do
          def subject.foobar(*args)
            :original_foobar
          end

          @method_name = :foobar
        end

        context "when method_name is a symbol" do
          it "returns double_injection and adds double_injection to double_injection list" do
            double_injection = Injections::DoubleInjection.find_or_create_by_subject(subject, method_name)
            Injections::DoubleInjection.find_or_create_by_subject(subject, method_name).should === double_injection
            double_injection.subject_class.should == (class << subject; self; end)
            double_injection.method_name.should === method_name
          end
        end

        context "when method_name is a string" do
          it "returns double_injection and adds double_injection to double_injection list" do
            double_injection = Injections::DoubleInjection.find_or_create_by_subject(subject, 'foobar')
            Injections::DoubleInjection.find_or_create_by_subject(subject, method_name).should === double_injection
            double_injection.subject_class.should == (class << subject; self; end)
            double_injection.method_name.should === method_name
          end
        end

        it "overrides the method when passing a block" do
          original_method = subject.method(:foobar)
          Injections::DoubleInjection.find_or_create_by_subject(subject, method_name)
          subject.method(:foobar).should_not == original_method
        end
      end

      context "when double_injection exists" do
        before do
          def subject.foobar(*args)
            :original_foobar
          end

          @method_name = :foobar
        end

        context "when a DoubleInjection is registered for the subject and method_name" do
          it "returns the existing DoubleInjection" do
            @double_injection = Injections::DoubleInjection.find_or_create_by_subject(subject, 'foobar')

            double_injection.subject_has_original_method?.should be_true

            Injections::DoubleInjection.find_or_create_by_subject(subject, 'foobar').should === double_injection

            double_injection.reset
            subject.foobar.should == :original_foobar
          end
        end
      end
    end

    describe "#method_missing_injection" do
      context "when existing subject == but not === with the same method name" do
        it "creates a new DoubleInjection" do
          subject_1 = []
          subject_2 = []
          (subject_1 === subject_2).should be_true
          subject_1.__id__.should_not == subject_2.__id__

          injection_1 = Injections::MethodMissingInjection.find_or_create(class << subject_1; self; end)
          injection_2 = Injections::MethodMissingInjection.find_or_create(class << subject_2; self; end)

          injection_1.should_not == injection_2
        end
      end

      context "when a MethodMissingInjection is not registered for the subject and method_name" do
        before do
          def subject.method_missing(method_name, *args, &block)
            :original_method_missing
          end
        end

        it "overrides the method when passing a block" do
          original_method = subject.method(:method_missing)
          Injections::MethodMissingInjection.find_or_create(class << subject; self; end)
          subject.method(:method_missing).should_not == original_method
        end
      end

      context "when a MethodMissingInjection is registered for the subject and method_name" do
        before do
          def subject.method_missing(method_name, *args, &block)
            :original_method_missing
          end
        end

        context "when a DoubleInjection is registered for the subject and method_name" do
          it "returns the existing DoubleInjection" do
            injection = Injections::MethodMissingInjection.find_or_create(class << subject; self; end)
            injection.subject_has_original_method?.should be_true

            Injections::MethodMissingInjection.find_or_create(class << subject; self; end).should === injection

            injection.reset
            subject.method_missing(:foobar).should == :original_method_missing
          end
        end
      end
    end

    describe "#singleton_method_added_injection" do
      context "when existing subject == but not === with the same method name" do
        it "creates a new DoubleInjection" do
          subject_1 = []
          subject_2 = []
          (subject_1 === subject_2).should be_true
          subject_1.__id__.should_not == subject_2.__id__

          injection_1 = Injections::SingletonMethodAddedInjection.find_or_create(class << subject_1; self; end)
          injection_2 = Injections::SingletonMethodAddedInjection.find_or_create(class << subject_2; self; end)

          injection_1.should_not == injection_2
        end
      end

      context "when a SingletonMethodAddedInjection is not registered for the subject and method_name" do
        before do
          def subject.singleton_method_added(method_name)
            :original_singleton_method_added
          end
        end

        it "overrides the method when passing a block" do
          original_method = subject.method(:singleton_method_added)
          Injections::SingletonMethodAddedInjection.find_or_create(class << subject; self; end)
          subject.method(:singleton_method_added).should_not == original_method
        end
      end

      context "when a SingletonMethodAddedInjection is registered for the subject and method_name" do
        before do
          def subject.singleton_method_added(method_name)
            :original_singleton_method_added
          end
        end

        context "when a DoubleInjection is registered for the subject and method_name" do
          it "returns the existing DoubleInjection" do
            injection = Injections::SingletonMethodAddedInjection.find_or_create(class << subject; self; end)
            injection.subject_has_original_method?.should be_true

            Injections::SingletonMethodAddedInjection.find_or_create(class << subject; self; end).should === injection

            injection.reset
            subject.singleton_method_added(:foobar).should == :original_singleton_method_added
          end
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
        space.record_call(object, :to_s, [], nil)

        space.reset
        space.recorded_calls.should == RR::RecordedCalls.new([])
      end

      it "removes the ordered doubles" do
        mock(subject_1).foobar1.ordered
        mock(subject_2).foobar2.ordered

        space.ordered_doubles.should_not be_empty

        space.reset
        space.ordered_doubles.should be_empty
      end

      it "resets all double_injections" do
        subject_1.respond_to?(method_name).should be_false
        subject_2.respond_to?(method_name).should be_false

        Injections::DoubleInjection.find_or_create_by_subject(subject_1, method_name)
        Injections::DoubleInjection.exists_by_subject?(subject_1, method_name).should be_true
        subject_1.respond_to?(method_name).should be_true

        Injections::DoubleInjection.find_or_create_by_subject(subject_2, method_name)
        Injections::DoubleInjection.exists_by_subject?(subject_2, method_name).should be_true
        subject_2.respond_to?(method_name).should be_true

        space.reset

        subject_1.respond_to?(method_name).should be_false
        Injections::DoubleInjection.exists?(subject_1, method_name).should be_false

        subject_2.respond_to?(method_name).should be_false
        Injections::DoubleInjection.exists?(subject_2, method_name).should be_false
      end

      it "resets all method_missing_injections" do
        subject_1.respond_to?(:method_missing).should be_false
        subject_2.respond_to?(:method_missing).should be_false

        Injections::MethodMissingInjection.find_or_create(class << subject_1; self; end)
        Injections::MethodMissingInjection.exists?(class << subject_1; self; end).should be_true
        subject_1.respond_to?(:method_missing).should be_true

        Injections::MethodMissingInjection.find_or_create(class << subject_2; self; end)
        Injections::MethodMissingInjection.exists?(class << subject_2; self; end).should be_true
        subject_2.respond_to?(:method_missing).should be_true

        space.reset

        subject_1.respond_to?(:method_missing).should be_false
        Injections::MethodMissingInjection.exists?(subject_1).should be_false

        subject_2.respond_to?(:method_missing).should be_false
        Injections::MethodMissingInjection.exists?(subject_2).should be_false
      end

      it "resets all singleton_method_added_injections" do
        subject_1.respond_to?(:singleton_method_added).should be_false
        subject_2.respond_to?(:singleton_method_added).should be_false

        Injections::SingletonMethodAddedInjection.find_or_create(class << subject_1; self; end)
        Injections::SingletonMethodAddedInjection.exists?(class << subject_1; self; end).should be_true
        subject_1.respond_to?(:singleton_method_added).should be_true

        Injections::SingletonMethodAddedInjection.find_or_create(class << subject_2; self; end)
        Injections::SingletonMethodAddedInjection.exists?(class << subject_2; self; end).should be_true
        subject_2.respond_to?(:singleton_method_added).should be_true

        space.reset

        subject_1.respond_to?(:singleton_method_added).should be_false
        Injections::SingletonMethodAddedInjection.exists?(subject_1).should be_false

        subject_2.respond_to?(:singleton_method_added).should be_false
        Injections::SingletonMethodAddedInjection.exists?(subject_2).should be_false
      end

      it "clears RR::Injections::DoubleInjection::BoundObjects" do
        stub(subject).foobar
        RR::Injections::DoubleInjection::BoundObjects.should_not be_empty
        space.reset
        pending "Clearing BoundObjects" do
          RR::Injections::DoubleInjection::BoundObjects.should be_empty
        end
      end
    end

    describe "#reset_double" do
      before do
        @method_name = :foobar

        def subject.foobar
        end
      end

      it "resets the double_injections and restores the original method" do
        original_method = subject.method(method_name)

        @double_injection = Injections::DoubleInjection.find_or_create_by_subject(subject, method_name)
        Injections::DoubleInjection.instances.keys.should include(class << subject; self; end)
        Injections::DoubleInjection.find_by_subject(subject, method_name).should_not be_nil
        subject.method(method_name).should_not == original_method

        space.reset_double(subject, method_name)
        Injections::DoubleInjection.instances.keys.should_not include(subject)
        subject.method(method_name).should == original_method
      end

      context "when it has no double_injections" do
        it "removes the subject from the double_injections map" do
          double_1 = Injections::DoubleInjection.find_or_create_by_subject(subject, :foobar1)
          double_2 = Injections::DoubleInjection.find_or_create_by_subject(subject, :foobar2)

          Injections::DoubleInjection.instances.include?(class << subject; self; end).should == true
          Injections::DoubleInjection.find_by_subject(subject, :foobar1).should_not be_nil
          Injections::DoubleInjection.find_by_subject(subject, :foobar2).should_not be_nil

          space.reset_double(subject, :foobar1)
          Injections::DoubleInjection.instances.include?(class << subject; self; end).should == true
          Injections::DoubleInjection.find_by_subject(subject, :foobar1).should be_nil
          Injections::DoubleInjection.find_by_subject(subject, :foobar2).should_not be_nil

          space.reset_double(subject, :foobar2)
          Injections::DoubleInjection.instances.include?(subject).should == false
        end
      end
    end

    describe "#DoubleInjection.reset" do
      attr_reader :subject_1, :subject_2
      before do
        @subject_1 = Object.new
        @subject_2 = Object.new
        @method_name = :foobar
      end

      it "resets the double_injection and removes it from the double_injections list" do
        double_injection_1 = Injections::DoubleInjection.find_or_create_by_subject(subject_1, method_name)
        double_1_reset_call_count = 0
        ( class << double_injection_1; self; end).class_eval do
          define_method(:reset) do
            double_1_reset_call_count += 1
          end
        end
        double_injection_2 = Injections::DoubleInjection.find_or_create_by_subject(subject_2, method_name)
        double_2_reset_call_count = 0
        ( class << double_injection_2; self; end).class_eval do
          define_method(:reset) do
            double_2_reset_call_count += 1
          end
        end

        Injections::DoubleInjection.reset
        double_1_reset_call_count.should == 1
        double_2_reset_call_count.should == 1
      end
    end

    describe "#verify_doubles" do
      attr_reader :subject_1, :subject_2, :subject3, :double_1, :double_2, :double3
      before do
        @subject_1 = Object.new
        @subject_2 = Object.new
        @subject3 = Object.new
        @method_name = :foobar
        @double_1 = Injections::DoubleInjection.find_or_create_by_subject(subject_1, method_name)
        @double_2 = Injections::DoubleInjection.find_or_create_by_subject(subject_2, method_name)
        @double3 = Injections::DoubleInjection.find_or_create_by_subject(subject3, method_name)
      end

      context "when passed no arguments" do
        it "verifies and deletes the double_injections" do
          double_1_verify_call_count = 0
          double_1_reset_call_count = 0
          (
          class << double_1;
            self;
          end).class_eval do
            define_method(:verify) do
              double_1_verify_call_count += 1
            end
            define_method(:reset) do
              double_1_reset_call_count += 1
            end
          end

          double_2_verify_call_count = 0
          double_2_reset_call_count = 0
          (
          class << double_2;
            self;
          end).class_eval do
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
          (
          class << double_1;
            self;
          end).class_eval do
            define_method(:verify) do
              double_1_verify_call_count += 1
            end
            define_method(:reset) do
              double_1_reset_call_count += 1
            end
          end

          double_2_verify_call_count = 0
          double_2_reset_call_count = 0
          (
          class << double_2;
            self;
          end).class_eval do
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
          ( class << double_1; self; end).class_eval do
            define_method(:verify) do
              double_1_verify_call_count += 1
            end
            define_method(:reset) do
              double_1_reset_call_count += 1
            end
          end

          double_2_verify_call_count = 0
          double_2_reset_call_count = 0
          ( class << double_2; self; end).class_eval do
            define_method(:verify) do
              double_2_verify_call_count += 1
            end
            define_method(:reset) do
              double_2_reset_call_count += 1
            end
          end

          double3_verify_call_count = 0
          double3_reset_call_count = 0
          ( class << double3; self; end).class_eval do
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
          ( class << double_1; self; end).class_eval do
            define_method(:verify) do
              double_1_verify_call_count += 1
            end
            define_method(:reset) do
              double_1_reset_call_count += 1
            end
          end

          double_2_verify_call_count = 0
          double_2_reset_call_count = 0
          ( class << double_2; self; end).class_eval do
            define_method(:verify) do
              double_2_verify_call_count += 1
            end
            define_method(:reset) do
              double_2_reset_call_count += 1
            end
          end

          double3_verify_call_count = 0
          double3_reset_call_count = 0
          ( class << double3; self; end).class_eval do
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

        def subject.foobar
        end
      end

      it "verifies and deletes the double_injection" do
        @double_injection = Injections::DoubleInjection.find_or_create_by_subject(subject, method_name)
        Injections::DoubleInjection.find_by_subject(subject, method_name).should === double_injection

        verify_call_count = 0
        ( class << double_injection; self; end).class_eval do
          define_method(:verify) do
            verify_call_count += 1
          end
        end
        space.verify_double(subject, method_name)
        verify_call_count.should == 1

        Injections::DoubleInjection.find(subject, method_name).should be_nil
      end

      context "when verifying the double_injection raises an error" do
        it "deletes the double_injection and restores the original method" do
          original_method = subject.method(method_name)

          @double_injection = Injections::DoubleInjection.find_or_create_by_subject(subject, method_name)
          subject.method(method_name).should_not == original_method

          Injections::DoubleInjection.find_by_subject(subject, method_name).should === double_injection

          verify_called = true
          ( class << double_injection; self; end).class_eval do
            define_method(:verify) do
              verify_called = true
              raise "An Error"
            end
          end
          lambda {space.verify_double(subject, method_name)}.should raise_error
          verify_called.should be_true

          Injections::DoubleInjection.find(subject, method_name).should be_nil
          subject.method(method_name).should == original_method
        end
      end
    end
  end
end