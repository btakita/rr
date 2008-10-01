require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe DoubleDefinitionCreator do
      class << self
        define_method("DoubleDefinitionCreator strategy definition") do
          describe DoubleDefinitionCreator, " strategy definition" do
            it "returns self when passing no args" do
              creator.__send__(method_name).should === creator
            end

            it "returns a DoubleDefinitionCreatorProxy when passed a subject" do
              double = creator.__send__(method_name, subject).foobar
              double.should be_instance_of(DoubleDefinition)
            end

            it "returns a DoubleDefinitionCreatorProxy when passed Kernel" do
              double = creator.__send__(method_name, Kernel).foobar
              double.should be_instance_of(DoubleDefinition)
            end

            it "raises error if passed a method name and a block" do
              lambda do
                creator.__send__(method_name, subject, :foobar) {}
              end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
            end

            it "raises error when using mock strategy" do
              creator.mock
              lambda do
                creator.__send__(method_name)
              end.should raise_error(
              Errors::DoubleDefinitionError,
              "This Double already has a mock strategy"
              )
            end

            it "raises error when using stub strategy" do
              creator.stub
              lambda do
                creator.__send__(method_name)
              end.should raise_error(
              Errors::DoubleDefinitionError,
              "This Double already has a stub strategy"
              )
            end

            it "raises error when using dont_allow strategy" do
              creator.dont_allow
              lambda do
                creator.__send__(method_name)
              end.should raise_error(
              Errors::DoubleDefinitionError,
              "This Double already has a dont_allow strategy"
              )
            end
          end
        end
      end

      attr_reader :creator, :subject, :space, :method_name
      it_should_behave_like "Swapped Space"
      before(:each) do
        @space = Space.instance
        @subject = Object.new
        @creator = DoubleDefinitionCreator.new
      end

      describe "#mock" do
        send("DoubleDefinitionCreator strategy definition")

        before do
          @method_name = :mock
        end

        it "sets up the RR mock call chain" do
          creates_mock_call_chain(creator.mock(subject))
        end

        it "sets up the DoubleDefinition to be in returns block_callback_strategy" do
          double = creator.mock(subject, :foobar)
          double.block_callback_strategy.should == :returns
        end

        def creates_mock_call_chain(creator)
          double = creator.foobar(1, 2) {:baz}
          double.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          double.argument_expectation.expected_arguments.should == [1, 2]

          subject.foobar(1, 2).should == :baz
        end

        context "when passed a second argument" do
          it "creates a mock Double for method" do
            creates_double_with_method_name( creator.mock(subject, :foobar) )
          end

          def creates_double_with_method_name(double)
            double.with(1, 2) {:baz}
            double.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
            double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
            double.argument_expectation.expected_arguments.should == [1, 2]

            subject.foobar(1, 2).should == :baz
          end
        end

        context "when passed method_name and block" do
          it "raises error" do
            lambda do
              @creator.mock(@subject, :foobar) {}
            end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
          end
        end
      end

      describe "#stub" do
        send("DoubleDefinitionCreator strategy definition")

        before do
          @method_name = :stub
        end

        it "sets up the RR stub call chain" do
          creates_stub_call_chain(creator.stub(subject))
        end

        it "sets up the DoubleDefinition to be in returns block_callback_strategy" do
          double = creator.stub(subject, :foobar)
          double.block_callback_strategy.should == :returns
        end

        context "when passed a second argument" do
          it "creates a stub Double for method when passed a second argument" do
            creates_double_with_method_name(creator.stub(subject, :foobar))
          end

          def creates_double_with_method_name(double)
            double.with(1, 2) {:baz}
            double.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
            double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
            subject.foobar(1, 2).should == :baz
          end
        end

        def creates_stub_call_chain(creator)
          double = creator.foobar(1, 2) {:baz}
          double.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          subject.foobar(1, 2).should == :baz
        end

        context "when passed method_name and block" do
          it "raises error" do
            lambda do
              @creator.stub(@subject, :foobar) {}
            end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
          end
        end
      end

      describe "#dont_allow" do
        send("DoubleDefinitionCreator strategy definition")

        before do
          @method_name = :dont_allow
        end

        it "raises error when proxied" do
          creator.proxy
          lambda do
            creator.dont_allow
          end.should raise_error(
          Errors::DoubleDefinitionError,
          "Doubles cannot be proxied when using dont_allow strategy"
          )
        end

        it "sets up the RR dont_allow call chain" do
          creates_dont_allow_call_chain(creator.dont_allow(subject))
        end

        it "sets up the RR dont_allow call chain" do
          creates_dont_allow_call_chain(creator.dont_call(subject))
        end

        it "sets up the RR dont_allow call chain" do
          creates_dont_allow_call_chain(creator.do_not_allow(subject))
        end

        it "sets up the RR dont_allow call chain" do
          creates_dont_allow_call_chain(creator.dont_allow(subject))
        end

        context "when passed a second argument_expectation" do
          it "creates a mock Double for method" do
            creates_double_with_method_name(creator.dont_allow(subject, :foobar))
          end

          it "creates a mock Double for method" do
            creates_double_with_method_name(creator.dont_call(subject, :foobar))
          end

          it "creates a mock Double for method" do
            creates_double_with_method_name(creator.do_not_allow(subject, :foobar))
          end

          it "creates a mock Double for method" do
            creates_double_with_method_name(creator.dont_allow(subject, :foobar))
          end

          def creates_double_with_method_name(double)
            double.with(1, 2)
            double.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(0)
            double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
            double.argument_expectation.expected_arguments.should == [1, 2]

            lambda do
              subject.foobar(1, 2)
            end.should raise_error(Errors::TimesCalledError)
            reset
            nil
          end
        end

        def creates_dont_allow_call_chain(creator)
          double = creator.foobar(1, 2)
          double.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(0)
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          double.argument_expectation.expected_arguments.should == [1, 2]

          lambda do
            subject.foobar(1, 2)
          end.should raise_error(Errors::TimesCalledError)
          reset
          nil
        end

        context "when passed method_name and block" do
          it "raises error" do
            lambda do
              @creator.dont_allow(@subject, :foobar) {}
            end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
          end
        end
      end

      describe "(#proxy or #proxy) and #stub" do
        before do
          class << subject
            def foobar(*args)
              :original_foobar
            end
          end
        end

        it "raises error when using dont_allow strategy" do
          creator.dont_allow
          lambda do
            creator.proxy
          end.should raise_error(
          Errors::DoubleDefinitionError,
          "Doubles cannot be proxied when using dont_allow strategy"
          )
        end

        it "sets up the RR proxy call chain" do
          double = creator.stub.proxy(subject).foobar(1, 2) {:baz}
          double.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          subject.foobar(1, 2).should == :baz
        end

        it "sets up the RR proxy call chain" do
          double = creator.stub.proxy(subject).foobar(1, 2) {:baz}
          double.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          subject.foobar(1, 2).should == :baz
        end

        context "when passed a second argument" do
          it "creates a proxy Double for method" do
            double = creator.stub.proxy(subject, :foobar)
            double.with(1, 2) {:baz}
            double.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
            double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
            subject.foobar(1, 2).should == :baz
          end

          it "creates a proxy Double for method" do
            double = creator.stub.proxy(subject, :foobar)
            double.with(1, 2) {:baz}
            double.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
            double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
            subject.foobar(1, 2).should == :baz
          end
        end

        it "sets up the DoubleDefinition to be in after_call block_callback_strategy" do
          def subject.foobar
            :original_implementation_value
          end

          args = nil
          double = creator.stub.proxy(subject, :foobar).with() do |*args|
            args = args
          end
          subject.foobar
          args.should == [:original_implementation_value]
          double.block_callback_strategy.should == :after_call
        end

        context "when passed method_name and block" do
          it "raises error" do
            lambda do
              @creator.proxy(@subject, :foobar) {}
            end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
          end
        end
      end

      describe "#instance_of" do
        it "raises an error when not passed a class" do
          lambda do
            creator.instance_of(Object.new)
          end.should raise_error(ArgumentError, "instance_of only accepts class objects")
        end

        it "sets up the RR proxy call chain" do
          klass = Class.new
          double = creator.stub.instance_of(klass).foobar(1, 2) {:baz}
          double.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          klass.new.foobar(1, 2).should == :baz
        end

        context "when passed a second argument" do
          it "creates a proxy Double for method" do
            klass = Class.new
            double = creator.stub.instance_of(klass, :foobar)
            double.with(1, 2) {:baz}
            double.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
            double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
            klass.new.foobar(1, 2).should == :baz
          end
        end

        it "raises error" do
          klass = Class.new
          lambda do
            @creator.instance_of(klass, :foobar) {}
          end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
        end
      end

      describe "#create using no strategy" do
        it "raises error" do
          lambda do
            creator.create(subject, :foobar, 1, 2)
          end.should raise_error(
          Errors::DoubleDefinitionError,
          "This Double has no strategy"
          )
        end
      end

      describe "#create using mock strategy" do
        before do
          creator.mock
        end

        it "sets expectations on the subject" do
          creator.create(subject, :foobar, 1, 2) {:baz}.twice

          subject.foobar(1, 2).should == :baz
          subject.foobar(1, 2).should == :baz
          lambda {subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
        end
      end

      describe "#create using stub strategy" do
        before do
          creator.stub
        end

        it "stubs the subject without any args" do
          creator.create(subject, :foobar) {:baz}
          subject.foobar.should == :baz
        end

        it "stubs the subject mapping passed in args with the output" do
          creator.create(subject, :foobar, 1, 2) {:one_two}
          creator.create(subject, :foobar, 1) {:one}
          creator.create(subject, :foobar) {:nothing}
          subject.foobar.should == :nothing
          subject.foobar(1).should == :one
          subject.foobar(1, 2).should == :one_two
        end
      end

      describe "#create using dont_allow strategy" do
        before do
          creator.dont_allow
        end

        it "sets expectation for method to never be called with any arguments when on arguments passed in" do
          creator.create(subject, :foobar)
          lambda {subject.foobar}.should raise_error(Errors::TimesCalledError)
          lambda {subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
        end

        it "sets expectation for method to never be called with passed in arguments" do
          creator.create(subject, :foobar, 1, 2)
          lambda {subject.foobar}.should raise_error(Errors::DoubleNotFoundError)
          lambda {subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
        end

        it "sets expectation for method to never be called with no arguments when with_no_args is set" do
          creator.create(subject, :foobar).with_no_args
          lambda {subject.foobar}.should raise_error(Errors::TimesCalledError)
          lambda {subject.foobar(1, 2)}.should raise_error(Errors::DoubleNotFoundError)
        end
      end

      describe "#create using mock strategy with proxy" do
        before do
          creator.mock
          creator.proxy
        end

        it "sets expectations on the subject while calling the original method" do
          def subject.foobar(*args)
            ; :baz;
          end
          creator.create(subject, :foobar, 1, 2).twice
          subject.foobar(1, 2).should == :baz
          subject.foobar(1, 2).should == :baz
          lambda {subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
        end

        it "sets after_call on the double when passed a block" do
          real_value = Object.new
          (class << subject; self; end).class_eval do
            define_method(:foobar) {real_value}
          end
          creator.create(subject, :foobar, 1, 2) do |value|
            mock(value).a_method {99}
            value
          end

          return_value = subject.foobar(1, 2)
          return_value.should === return_value
          return_value.a_method.should == 99
        end
      end

      describe "#create using stub strategy with proxy" do
        before do
          creator.stub
          creator.proxy
        end

        it "sets up a double with passed in arguments" do
          def subject.foobar(*args)
            :baz
          end
          creator.create(subject, :foobar, 1, 2)
          lambda do
            subject.foobar
          end.should raise_error(Errors::DoubleNotFoundError)
        end

        it "sets expectations on the subject while calling the original method" do
          def subject.foobar(*args)
            :baz
          end
          creator.create(subject, :foobar, 1, 2) {:new_value}
          10.times do
            subject.foobar(1, 2).should == :new_value
          end
        end

        it "sets after_call on the double when passed a block" do
          real_value = Object.new
          (class << subject; self; end).class_eval do
            define_method(:foobar) {real_value}
          end
          creator.create(subject, :foobar, 1, 2) do |value|
            mock(value).a_method {99}
            value
          end

          return_value = subject.foobar(1, 2)
          return_value.should === return_value
          return_value.a_method.should == 99
        end
      end

      describe "#instance_of and #mock" do
        before do
          @klass = Class.new
        end

        it "returns a DoubleDefinitionCreator when passed no arguments" do
          instance_of.instance_of.should be_instance_of(DoubleDefinitionCreator)
        end

        it "sets up the RR instance_of call chain" do
          creates_instance_of_call_chain(instance_of.mock(@klass))
        end

        it "#rr_instance_of sets up the RR instance_of call chain" do
          creates_instance_of_call_chain(rr_instance_of.mock(@klass))
        end

        it "creates a instance_of Double for method when passed a second argument" do
          creates_double_with_method_name(instance_of.mock(@klass, :foobar))
        end

        it "creates a instance_of Double for method when passed a second argument with rr_instance_of" do
          creates_double_with_method_name(rr_instance_of.mock(@klass, :foobar))
        end

        it "raises error if passed a method name and a block" do
          lambda do
            instance_of.mock(@klass, :foobar) {}
          end.should raise_error(ArgumentError, "Cannot pass in a method name and a block")
        end

        def creates_double_with_method_name(double)
          double.with(1, 2) {:baz}
          double.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          double.argument_expectation.expected_arguments.should == [1, 2]

          @klass.new.foobar(1, 2).should == :baz
        end

        def creates_instance_of_call_chain(creator)
          double = creator.foobar(1, 2) {:baz}
          double.times_matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
          double.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
          double.argument_expectation.expected_arguments.should == [1, 2]

          @klass.new.foobar(1, 2).should == :baz
        end
      end      
    end
  end
end