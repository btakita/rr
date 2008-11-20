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
      @definition = DoubleDefinitions::DoubleDefinition.new(definition_creator, subject).
        any_number_of_times.
        with_any_args
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

    describe "#ordered?" do
      it "defaults to false" do
        double.should_not be_ordered
      end
    end

    describe "#call" do
      describe "when verbose" do
        it "prints the message call" do
          double.definition.verbose
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
          double.definition.returns {|arg| "returning #{arg}"}
          double.call(double_injection, :foobar).should == "returning foobar"
        end

        it "calls and returns the after_call when after_call is set" do
          double.definition.returns {|arg| "returning #{arg}"}.after_call do |value|
            "#{value} after call"
          end
          double.call(double_injection, :foobar).should == "returning foobar after call"
        end

        it "returns nil when to returns is not set" do
          double.call(double_injection).should be_nil
        end

        it "works when times_called is not set" do
          double.definition.returns {:value}
          double.call(double_injection)
        end

        it "verifes the times_called does not exceed the TimesCalledExpectation" do
          double.definition.times(2).returns {:value}

          double.call(double_injection, :foobar)
          double.call(double_injection, :foobar)
          lambda {double.call(double_injection, :foobar)}.should raise_error(Errors::TimesCalledError)
        end

        it "raises DoubleOrderError when ordered and called out of order" do
          double1 = double
          double2 = Double.new(double_injection, DoubleDefinitions::DoubleDefinition.new(definition_creator, subject))

          double1.definition.with(1).returns {:return_1}.once.ordered
          double2.definition.with(2).returns {:return_2}.once.ordered

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

          double.definition.returns {:value}.ordered
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

          double.definition.returns {:value}
          double.call(double_injection, :foobar)
          verify_ordered_double_called.should be_false
        end

        it "does not add block argument if no block passed in" do
          double.definition.with(1, 2).returns {|*args| args}

          args = subject.foobar(1, 2)
          args.should == [1, 2]
        end

        it "makes the block the last argument" do
          double.definition.with(1, 2).returns {|a, b, blk| blk}

          block = subject.foobar(1, 2) {|a, b| [b, a]}
          block.call(3, 4).should == [4, 3]
        end

        it "raises ArgumentError when yields was called and no block passed in" do
          double.definition.with(1, 2).yields(55)

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

          double.definition.with(1, 2).implemented_by(subject.method(:foobar))

          subject.foobar(1, 2) {|a, b| [b, a]}.should == [2, 1]
        end
      end
    end

    describe "#exact_match?" do
      context "when no expectation is set" do
        it "raises a DoubleDefinitionError" do
          double.definition.argument_expectation = nil
          lambda do
            double.exact_match?
          end.should raise_error(Errors::DoubleDefinitionError)
        end
      end

      context "when arguments are not an exact match" do
        it "returns false" do
          double.definition.with(1, 2, 3)
          double.should_not be_exact_match(1, 2)
          double.should_not be_exact_match(1)
          double.should_not be_exact_match()
          double.should_not be_exact_match("does not match")
        end
      end

      context "when arguments are an exact match" do
        it "returns true" do
          double.definition.with(1, 2, 3)
          double.should be_exact_match(1, 2, 3)
        end
      end
    end

    describe "#wildcard_match?" do
      context "when no expectation set" do
        it "raises a DoubleDefinitionError" do
          double.definition.argument_expectation = nil
          lambda do
            double.wildcard_match?
          end.should raise_error(Errors::DoubleDefinitionError)
        end
      end

      context "when arguments are an exact match" do
        it "returns true" do
          double.definition.with(1, 2, 3)
          double.should be_wildcard_match(1, 2, 3)
          double.should_not be_wildcard_match(1, 2)
          double.should_not be_wildcard_match(1)
          double.should_not be_wildcard_match()
          double.should_not be_wildcard_match("does not match")
        end
      end

      context "when with_any_args" do
        it "returns true" do
          double.definition.with_any_args

          double.should be_wildcard_match(1, 2, 3)
          double.should be_wildcard_match(1, 2)
          double.should be_wildcard_match(1)
          double.should be_wildcard_match()
          double.should be_wildcard_match("does not match")
        end
      end
    end

    describe "#attempt?" do
      context "when TimesCalledExpectation#attempt? is true" do
        it "returns true" do
          double.definition.with(1, 2, 3).twice
          double.call(double_injection, 1, 2, 3)
          double.times_called_expectation.should be_attempt
          double.should be_attempt
        end
      end

      context "when TimesCalledExpectation#attempt? is true" do
        it "returns false" do
          double.definition.with(1, 2, 3).twice
          double.call(double_injection, 1, 2, 3)
          double.call(double_injection, 1, 2, 3)
          double.times_called_expectation.should_not be_attempt
          double.should_not be_attempt
        end
      end

      context "when there is no Times Called expectation" do
        it "raises a DoubleDefinitionError" do
          double.definition.with(1, 2, 3)
          double.definition.times_matcher = nil
          lambda do
            double.should be_attempt
          end.should raise_error(RR::Errors::DoubleDefinitionError)
        end
      end
    end

    describe "#verify" do
      it "verifies that times called expectation was met" do
        double.definition.twice.returns {:return_value}

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
      context "when times_called_expectation's terminal? is true" do
        it "returns true" do
          double.definition.once
          double.times_called_expectation.should be_terminal
          double.should be_terminal
        end
      end

      context "when times_called_expectation's terminal? is false" do
        it "returns false" do
          double.definition.any_number_of_times
          double.times_called_expectation.should_not be_terminal
          double.should_not be_terminal
        end
      end

      context "when there is no times_matcher" do
        it "raises a DoubleDefinitionError" do
          double.definition.times_matcher = nil
          lambda do
            double.should_not be_terminal
          end.should raise_error(RR::Errors::DoubleDefinitionError)
        end
      end
    end

    describe "#method_name" do
      it "returns the DoubleInjection's method_name" do
        double_injection.method_name.should == :foobar
        double.method_name.should == :foobar
      end
    end

    describe "#expected_arguments" do
      context "when there is an argument expectation" do
        it "returns argument expectation's expected_arguments" do
          double.definition.with(1, 2)
          double.definition.argument_expectation.should_not be_nil
          double.expected_arguments.should == [1, 2]
        end
      end

      context "when there is no argument expectation" do
        it "raises an DoubleDefinitionError" do
          double.definition.argument_expectation = nil
          lambda do
            double.expected_arguments
          end.should raise_error(Errors::DoubleDefinitionError)
        end
      end
    end

    describe "#formatted_name" do
      it "renders the formatted name of the Double with no arguments" do
        double.formatted_name.should == "foobar()"
      end

      it "renders the formatted name of the Double with arguments" do
        double.definition.with(1, 2)
        double.formatted_name.should == "foobar(1, 2)"
      end
    end
  end
end