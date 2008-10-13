require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

module RR
  describe Double do
    it_should_behave_like "Swapped Space"
    attr_reader :subject, :double_injection, :definition, :definition_creator, :double
    before do
      @subject = Object.new
      def subject.foobar(a, b)
        [b, a]
      end
      @double_injection = create_double_injection
      @definition_creator = DoubleDefinitions::DoubleDefinitionCreator.new
      @definition = DoubleDefinitions::DoubleDefinition.new(definition_creator, subject)
      @double = Double.new(double_injection, definition)
    end

    def create_double_injection
      space.double_injection(subject, :foobar)
    end

    describe "#initialize" do
      it "registers self with associated DoubleInjection" do
        double_injection.doubles.should include(double)
      end
    end

    describe "#with" do
      it "returns DoubleDefinition" do
        double.with(1).should === double.definition
      end

      it "sets an ArgumentEqualityExpectation" do
        double.with(1)
        double.should be_exact_match(1)
        double.should_not be_exact_match(2)
      end

      it "sets return value when block passed in" do
        double.with(1) {:return_value}
        subject.foobar(1).should == :return_value
      end
    end

    describe "#with_any_args" do
      before do
        double.with_any_args {:return_value}
      end

      it "returns DoubleDefinition" do
        double.with_no_args.should === double.definition
      end

      it "sets an AnyArgumentExpectation" do
        double.should_not be_exact_match(1)
        double.should be_wildcard_match(1)
      end

      it "sets return value when block passed in" do
        subject.foobar(:anything).should == :return_value
      end
    end

    describe "#with_no_args" do
      before do
        double.with_no_args {:return_value}
      end

      it "returns DoubleDefinition" do
        double.with_no_args.should === double.definition
      end

      it "sets an ArgumentEqualityExpectation with no arguments" do
        double.argument_expectation.should == Expectations::ArgumentEqualityExpectation.new()
      end

      it "sets return value when block passed in" do
        subject.foobar().should == :return_value
      end
    end

    describe "#never" do
      it "returns DoubleDefinition" do
        double.never.should === double.definition
      end

      it "sets up a Times Called Expectation with 0" do
        double.never
        lambda {double.call(double_injection)}.should raise_error(Errors::TimesCalledError)
      end

      it "sets return value when block passed in" do
        double.with_any_args.never
        lambda {double.call(double_injection)}.should raise_error(Errors::TimesCalledError)
      end
    end

    describe "#once" do
      it "returns DoubleDefinition" do
        double.once.should === double.definition
      end

      it "sets up a Times Called Expectation with 1" do
        double.once
        double.call(double_injection)
        lambda {double.call(double_injection)}.should raise_error(Errors::TimesCalledError)
      end

      it "sets return value when block passed in" do
        double.with_any_args.once {:return_value}
        subject.foobar.should == :return_value
      end
    end

    describe "#twice" do
      it "returns DoubleDefinition" do
        double.twice.should === double.definition
      end

      it "sets up a Times Called Expectation with 2" do
        double.twice
        double.call(double_injection)
        double.call(double_injection)
        lambda {double.call(double_injection)}.should raise_error(Errors::TimesCalledError)
      end

      it "sets return value when block passed in" do
        double.with_any_args.twice {:return_value}
        subject.foobar.should == :return_value
      end
    end

    describe "#at_least" do
      it "returns DoubleDefinition" do
        double.with_any_args.at_least(2).should === double.definition
      end

      it "sets up a AtLeastMatcher with 2" do
        double.at_least(2)
        double.definition.times_matcher.should == TimesCalledMatchers::AtLeastMatcher.new(2)
      end

      it "sets return value when block passed in" do
        double.with_any_args.at_least(2) {:return_value}
        subject.foobar.should == :return_value
      end
    end

    describe "#at_most" do
      it "returns DoubleDefinition" do
        double.with_any_args.at_most(2).should === double.definition
      end

      it "sets up a Times Called Expectation with 1" do
        double.at_most(2)
        double.call(double_injection)
        double.call(double_injection)
        lambda do
          double.call(double_injection)
        end.should raise_error(
        Errors::TimesCalledError,
        "foobar()\nCalled 3 times.\nExpected at most 2 times."
        )
      end

      it "sets return value when block passed in" do
        double.with_any_args.at_most(2) {:return_value}
        subject.foobar.should == :return_value
      end
    end

    describe "#times" do
      it "returns DoubleDefinition" do
        double.times(3).should === double.definition
      end

      it "sets up a Times Called Expectation with passed in times" do
        double.times(3)
        double.call(double_injection)
        double.call(double_injection)
        double.call(double_injection)
        lambda {double.call(double_injection)}.should raise_error(Errors::TimesCalledError)
      end

      it "sets return value when block passed in" do
        double.with_any_args.times(3) {:return_value}
        subject.foobar.should == :return_value
      end
    end

    describe "#any_number_of_times" do
      it "returns DoubleDefinition" do
        double.any_number_of_times.should === double.definition
      end

      it "sets up a Times Called Expectation with AnyTimes matcher" do
        double.any_number_of_times
        double.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
      end

      it "sets return value when block passed in" do
        double.with_any_args.any_number_of_times {:return_value}
        subject.foobar.should == :return_value
      end
    end

    describe "#ordered" do
      it "adds itself to the ordered doubles list" do
        double.ordered
        space.ordered_doubles.should include(double)
      end

      it "does not double_injection add itself" do
        double.ordered
        double.ordered
        space.ordered_doubles.should == [double ]
      end

      it "sets ordered? to true" do
        double.ordered
        double.should be_ordered
      end

      it "sets return value when block passed in" do
        double.with_any_args.once.ordered {:return_value}
        subject.foobar.should == :return_value
      end
    end

    describe "#ordered?" do
      it "defaults to false" do
        double.should_not be_ordered
      end
    end

    describe "#yields" do
      it "returns DoubleDefinition" do
        double.yields(:baz).should === double.definition
      end

      it "yields the passed in argument to the call block when there is no returns value set" do
        double.with_any_args.yields(:baz)
        passed_in_block_arg = nil
        subject.foobar {|arg| passed_in_block_arg = arg}.should == nil
        passed_in_block_arg.should == :baz
      end

      it "yields the passed in argument to the call block when there is a no returns value set" do
        double.with_any_args.yields(:baz).returns(:return_value)

        passed_in_block_arg = nil
        subject.foobar {|arg| passed_in_block_arg = arg}.should == :return_value
        passed_in_block_arg.should == :baz
      end

      it "sets return value when block passed in" do
        double.with_any_args.yields {:return_value}
        subject.foobar {}.should == :return_value
      end
    end

    describe "#after_call" do
      it "returns DoubleDefinition" do
        double.after_call {}.should === double.definition
      end

      it "sends return value of Double implementation to after_call" do
        return_value = {}
        double.returns(return_value).after_call do |value|
          value[:foo] = :bar
          value
        end

        actual_value = double.call(double_injection)
        actual_value.should === return_value
        actual_value.should == {:foo => :bar}
      end

      it "receives the return value in the after_call callback" do
        return_value = :returns_value
        double.returns(return_value).after_call do |value|
          :after_call_proc
        end

        actual_value = double.call(double_injection)
        actual_value.should == :after_call_proc
      end

      it "allows after_call to mock the return value" do
        return_value = Object.new
        double.with_any_args.returns(return_value).after_call do |value|
          mock(value).inner_method(1) {:baz}
          value
        end

        subject.foobar.inner_method(1).should == :baz
      end

      it "raises an error when not passed a block" do
        lambda do
          double.after_call
        end.should raise_error(ArgumentError, "after_call expects a block")
      end
    end

    describe "#verbose" do
      it "returns DoubleDefinition" do
        double.verbose.should === double.definition
      end

      it "sets #verbose? to true" do
        double.should_not be_verbose
        double.verbose
        double.should be_verbose
      end

      it "sets return value when block passed in" do
        (class << double; self; end).__send__(:define_method, :puts) {|value|}
        double.with().verbose {:return_value}
        subject.foobar.should == :return_value
      end
    end

    describe "#returns" do
      it "returns DoubleDefinition" do
        double.returns {:baz}.should === double.definition
        double.returns(:baz).should === double.definition
      end

      context "when passed a block" do
        context "when the block returns a DoubleDefinition" do
          it "causes #call to return the #subject of the DoubleDefinition" do
            new_subject = Object.new
            double.returns do
              definition = stub(new_subject).foobar
              definition.class.should == DoubleDefinitions::DoubleDefinition
              definition
            end
            double.call(double_injection).should == new_subject
          end
        end

        context "when the block returns a DoubleDefinitionCreatorProxy" do
          it "causes #call to return the #subject of the DoubleDefinition" do
            new_subject = Object.new
            double.returns do
              stub(new_subject)
            end
            double.call(double_injection).should == new_subject
          end
        end

        context "when the block returns an Object" do
          it "causes #call to return the value of the block" do
            double.returns {:baz}
            double.call(double_injection).should == :baz
          end          
        end
      end

      context "when passed a return value argument" do
        context "when passed a DoubleDefinition" do
          it "causes #call to return the #subject of the DoubleDefinition" do
            new_subject = Object.new
            definition = stub(new_subject).foobar
            definition.class.should == DoubleDefinitions::DoubleDefinition
            
            double.returns(definition)
            double.call(double_injection).should == new_subject
          end
        end

        context "when passed a DoubleDefinitionCreatorProxy" do
          it "causes #call to return the #subject of the DoubleDefinition" do
            new_subject = Object.new
            proxy = stub(new_subject)
            proxy.__creator__.subject.should == new_subject

            double.returns(proxy)
            double.call(double_injection).should == new_subject
          end
        end

        context "when passed an Object" do
          it "causes #call to return the Object" do
            double.returns(:baz)
            double.call(double_injection).should == :baz
          end
        end

        context "when passed false" do
          it "causes #call to return false" do
            double.returns(false)
            double.call(double_injection).should == false
          end
        end        
      end

      context "when passed both a return value argument and a block" do
        it "raises an error" do
          lambda do
            double.returns(:baz) {:another}
          end.should raise_error(ArgumentError, "returns cannot accept both an argument and a block")
        end
      end
    end

    describe "#implemented_by" do
      it "returns the DoubleDefinition" do
        double.implemented_by(lambda{:baz}).should === double.definition
      end

      it "sets the implementation to the passed in Proc" do
        double.implemented_by(lambda{:baz})
        double.call(double_injection).should == :baz
      end

      it "sets the implementation to the passed in method" do
        def subject.foobar(a, b)
          [b, a]
        end
        double.implemented_by(subject.method(:foobar))
        double.call(double_injection, 1, 2).should == [2, 1]
      end
    end

    describe "#call" do
      describe "when verbose" do
        it "prints the message call" do
          double.verbose
          output = nil
          (class << double; self; end).__send__(:define_method, :puts) do |output|
            output = output
          end
          double.call(double_injection, 1, 2)
          output.should == Double.formatted_name(:foobar, [1, 2])
        end
      end

      describe "when not verbose" do
        it "does not print the message call" do
          output = nil
          (class << double; self; end).__send__(:define_method, :puts) do |output|
            output = output
          end
          double.call(double_injection, 1, 2)
          output.should be_nil
        end
      end

      describe "when implemented by a lambda" do
        it "calls the return lambda when implemented by a lambda" do
          double.returns {|arg| "returning #{arg}"}
          double.call(double_injection, :foobar).should == "returning foobar"
        end

        it "calls and returns the after_call when after_call is set" do
          double.returns {|arg| "returning #{arg}"}.after_call do |value|
            "#{value} after call"
          end
          double.call(double_injection, :foobar).should == "returning foobar after call"
        end

        it "returns nil when to returns is not set" do
          double.call(double_injection).should be_nil
        end

        it "works when times_called is not set" do
          double.returns {:value}
          double.call(double_injection)
        end

        it "verifes the times_called does not exceed the TimesCalledExpectation" do
          double.times(2).returns {:value}

          double.call(double_injection, :foobar)
          double.call(double_injection, :foobar)
          lambda {double.call(double_injection, :foobar)}.should raise_error(Errors::TimesCalledError)
        end

        it "raises DoubleOrderError when ordered and called out of order" do
          double1 = double
          double2 = Double.new(double_injection, DoubleDefinitions::DoubleDefinition.new(definition_creator, subject))

          double1.with(1).returns {:return_1}.once.ordered
          double2.with(2).returns {:return_2}.once.ordered

          lambda do
            subject.foobar(2)
          end.should raise_error(
          Errors::DoubleOrderError,
          "foobar(2) called out of order in list\n" <<
          "- foobar(1)\n" <<
          "- foobar(2)"
          )
        end

        it "dispatches to Space#verify_ordered_double when ordered" do
          verify_ordered_double_called = false
          passed_in_double = nil
          space.method(:verify_ordered_double).arity.should == 1
          (class << space; self; end).class_eval do
            define_method :verify_ordered_double do |double|
              passed_in_double = double
              verify_ordered_double_called = true
            end
          end

          double.returns {:value}.ordered
          double.call(double_injection, :foobar)
          verify_ordered_double_called.should be_true
          passed_in_double.should === double
        end

        it "does not dispatche to Space#verify_ordered_double when not ordered" do
          verify_ordered_double_called = false
          space.method(:verify_ordered_double).arity.should == 1
          (class << space; self; end).class_eval do
            define_method :verify_ordered_double do |double|
              verify_ordered_double_called = true
            end
          end

          double.returns {:value}
          double.call(double_injection, :foobar)
          verify_ordered_double_called.should be_false
        end

        it "does not add block argument if no block passed in" do
          double.with(1, 2).returns {|*args| args}

          args = subject.foobar(1, 2)
          args.should == [1, 2]
        end

        it "makes the block the last argument" do
          double.with(1, 2).returns {|a, b, blk| blk}

          block = subject.foobar(1, 2) {|a, b| [b, a]}
          block.call(3, 4).should == [4, 3]
        end

        it "raises ArgumentError when yields was called and no block passed in" do
          double.with(1, 2).yields(55)

          lambda do
            subject.foobar(1, 2)
          end.should raise_error(ArgumentError, "A Block must be passed into the method call when using yields")
        end
      end

      describe "when implemented by a method" do
        it "sends block to the method" do
          def subject.foobar(a, b)
            yield(a, b)
          end

          double.with(1, 2).implemented_by(subject.method(:foobar))

          subject.foobar(1, 2) {|a, b| [b, a]}.should == [2, 1]
        end
      end
    end

    describe "#exact_match?" do
      context "when no expectation is set" do
        it "raises a DoubleDefinitionError" do
          lambda do
            double.exact_match?
          end.should raise_error(Errors::DoubleDefinitionError)
        end
      end

      context "when arguments are not an exact match" do
        it "returns false" do
          double.with(1, 2, 3)
          double.should_not be_exact_match(1, 2)
          double.should_not be_exact_match(1)
          double.should_not be_exact_match()
          double.should_not be_exact_match("does not match")
        end
      end

      context "when arguments are an exact match" do
        it "returns true" do
          double.with(1, 2, 3)
          double.should be_exact_match(1, 2, 3)
        end
      end
    end

    describe "#wildcard_match?" do
      context "when no expectation set" do
        it "raises a DoubleDefinitionError" do
          lambda do
            double.wildcard_match?
          end.should raise_error(Errors::DoubleDefinitionError)
        end
      end

      context "when arguments are an exact match" do
        it "returns true" do
          double.with(1, 2, 3)
          double.should be_wildcard_match(1, 2, 3)
          double.should_not be_wildcard_match(1, 2)
          double.should_not be_wildcard_match(1)
          double.should_not be_wildcard_match()
          double.should_not be_wildcard_match("does not match")
        end
      end

      context "when with_any_args" do
        it "returns true" do
          double.with_any_args

          double.should be_wildcard_match(1, 2, 3)
          double.should be_wildcard_match(1, 2)
          double.should be_wildcard_match(1)
          double.should be_wildcard_match()
          double.should be_wildcard_match("does not match")
        end
      end
    end

    describe "#attempt?" do
      it "returns true when TimesCalledExpectation#attempt? is true" do
        double.with(1, 2, 3).twice
        double.call(double_injection, 1, 2, 3)
        double.times_called_expectation.should be_attempt
        double.should be_attempt
      end

      it "returns false when TimesCalledExpectation#attempt? is true" do
        double.with(1, 2, 3).twice
        double.call(double_injection, 1, 2, 3)
        double.call(double_injection, 1, 2, 3)
        double.times_called_expectation.should_not be_attempt
        double.should_not be_attempt
      end

      it "returns true when there is no Times Called expectation" do
        double.with(1, 2, 3)
        double.definition.times_matcher.should be_nil
        double.should be_attempt
      end
    end

    describe "#verify" do
      it "verifies that times called expectation was met" do
        double.twice.returns {:return_value}

        lambda {double.verify}.should raise_error(Errors::TimesCalledError)
        double.call(double_injection)
        lambda {double.verify}.should raise_error(Errors::TimesCalledError)
        double.call(double_injection)

        lambda {double.verify}.should_not raise_error
      end

      it "does not raise an error when there is no times called expectation" do
        lambda {double.verify}.should_not raise_error
        double.call(double_injection)
        lambda {double.verify}.should_not raise_error
        double.call(double_injection)
        lambda {double.verify}.should_not raise_error
      end
    end

    describe "#terminal?" do
      it "returns true when times_called_expectation's terminal? is true" do
        double.once
        double.times_called_expectation.should be_terminal
        double.should be_terminal
      end

      it "returns false when times_called_expectation's terminal? is false" do
        double.any_number_of_times
        double.times_called_expectation.should_not be_terminal
        double.should_not be_terminal
      end

      it "returns false when there is no times_matcher" do
        double.definition.times_matcher.should be_nil
        double.should_not be_terminal
      end
    end

    describe "#method_name" do
      it "returns the DoubleInjection's method_name" do
        double_injection.method_name.should == :foobar
        double.method_name.should == :foobar
      end
    end

    describe "#expected_arguments" do
      it "returns argument expectation's expected_arguments when there is a argument expectation" do
        double.with(1, 2)
        double.expected_arguments.should == [1, 2]
      end

      it "returns an empty array when there is no argument expectation" do
        double.argument_expectation.should be_nil
        double.expected_arguments.should == []
      end
    end

    describe "#formatted_name" do
      it "renders the formatted name of the Double with no arguments" do
        double.formatted_name.should == "foobar()"
      end

      it "renders the formatted name of the Double with arguments" do
        double.with(1, 2)
        double.formatted_name.should == "foobar(1, 2)"
      end
    end
  end
end