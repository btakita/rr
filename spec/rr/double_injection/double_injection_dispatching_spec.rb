require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  describe DoubleInjection do
    attr_reader :space, :subject, :double_injection
    it_should_behave_like "Swapped Space"
    before do
      @subject = Object.new
      subject.methods.should_not include(method_name.to_s)
      @double_injection = space.double_injection(subject, method_name)
    end

    def new_double
      Double.new(
        double_injection,
        DoubleDefinitions::DoubleDefinition.new(
          DoubleDefinitions::DoubleDefinitionCreator.new,
          subject
        ).any_number_of_times
      )
    end

    describe "methods whose name do not contain ! or ?" do
      def method_name
        :foobar
      end

      context "when the original method uses the passed-in block" do
        it "executes the passed-in block" do
          method_fixture = Object.new
          class << method_fixture
            def method_with_block(a, b)
              yield(a, b)
            end
          end
          double = new_double
          double.definition.with(1, 2).implemented_by(method_fixture.method(:method_with_block))
          subject.foobar(1, 2) {|a, b| [b, a]}.should == [2, 1]
        end
      end

      context "when no other Double with duplicate ArgumentExpectations exists" do
        it "dispatches to Double that have an exact match" do
          double1_with_exact_match = new_double
          double1_with_exact_match.definition.with(:exact_match_1).returns {:return_1}
          double_with_no_match = new_double
          double_with_no_match.definition.with("nothing that matches").returns {:no_match}
          double2_with_exact_match = new_double
          double2_with_exact_match.definition.with(:exact_match_2).returns {:return_2}

          subject.foobar(:exact_match_1).should == :return_1
          subject.foobar(:exact_match_2).should == :return_2
        end

        it "dispatches to Double that have a wildcard match" do
          double_with_wildcard_match = new_double
          double_with_wildcard_match.definition.with_any_args.returns {:wild_card_value}
          double_with_no_match = new_double
          double_with_no_match.definition.with("nothing that matches").returns {:no_match}

          subject.foobar(:wildcard_match_1).should == :wild_card_value
          subject.foobar(:wildcard_match_2, 3).should == :wild_card_value
        end
      end

      context "when other Doubles exists but none of them match the passed-in arguments" do
        it "raises DoubleNotFoundError error when arguments do not match a double" do
          double_1 = new_double
          double_1.definition.with(1, 2)

          double_2 = new_double
          double_2.definition.with(3)

          error = nil
          begin
            subject.foobar(:arg1, :arg2)
            viotated "Error should have been raised"
          rescue Errors::DoubleNotFoundError => e
            error = e
          end
          error.message.should include("On subject #<Object")
          expected_double_message_part = "unexpected method invocation:\n" <<
            "  foobar(:arg1, :arg2)\n"
            "expected invocations:\n"
            "- foobar(1, 2)\n" <<
            "- foobar(3)"
          error.message.should include(expected_double_message_part)
        end
      end

      context "when at least one Double with NonTerminal TimesCalledMatchers exits" do
        it "dispatches to Double with exact match" do
          double = new_double(1, 2) {:return_value}
          subject.foobar(1, 2).should == :return_value
        end

        it "matches to the last Double that was registered with an exact match" do
          double_1 = new_double(1, 2) {:value_1}
          double_2 = new_double(1, 2) {:value_2}

          subject.foobar(1, 2).should == :value_2
        end

        it "dispatches to Double with wildcard match" do
          double = new_double(anything) {:return_value}
          subject.foobar(:dont_care).should == :return_value
        end

        it "matches to the last Double that was registered with a wildcard match" do
          double_1 = new_double(anything) {:value_1}
          double_2 = new_double(anything) {:value_2}

          subject.foobar(:dont_care).should == :value_2
        end

        it "matches to Double with exact match Double even when a Double with wildcard match was registered later" do
          exact_double_registered_first = new_double(1, 2) {:exact_first}
          wildcard_double_registered_last = new_double(anything, anything) {:wildcard_last}

          subject.foobar(1, 2).should == :exact_first
        end

        def new_double(*arguments, &return_value)
          double = super()
          double.definition.with(*arguments).any_number_of_times.returns(&return_value)
          double.should_not be_terminal
          double
        end
      end

      context "when two or more Terminal Doubles with duplicate Exact Match ArgumentExpectations exists" do
        it "dispatches to Double that have an exact match" do
          double1_with_exact_match = new_double(:exact_match) {:return_1}

          subject.foobar(:exact_match).should == :return_1
        end

        it "dispatches to the first Double that have an exact match" do
          double1_with_exact_match = new_double(:exact_match) {:return_1}
          double2_with_exact_match = new_double(:exact_match) {:return_2}

          subject.foobar(:exact_match).should == :return_1
        end

        it "dispatches the second Double with an exact match
          when the first double's Times Called expectation is satisfied" do
          double1_with_exact_match = new_double(:exact_match) {:return_1}
          double2_with_exact_match = new_double(:exact_match) {:return_2}

          subject.foobar(:exact_match)
          subject.foobar(:exact_match).should == :return_2
        end

        it "raises TimesCalledError when all of the doubles Times Called expectation is satisfied" do
          double1_with_exact_match = new_double(:exact_match) {:return_1}
          double2_with_exact_match = new_double(:exact_match) {:return_2}

          subject.foobar(:exact_match)
          subject.foobar(:exact_match)
          lambda do
            subject.foobar(:exact_match)
          end.should raise_error(Errors::TimesCalledError)
        end

        def new_double(*arguments, &return_value)
          double = super()
          double.definition.with(*arguments).once.returns(&return_value)
          double.should be_terminal
          double
        end
      end

      context "when two or more Doubles with duplicate Wildcard Match ArgumentExpectations exists" do
        it "dispatches to Double that have a wildcard match" do
          double_1 = new_double {:return_1}

          subject.foobar(:anything).should == :return_1
        end

        it "dispatches to the first Double that has a wildcard match" do
          double_1 = new_double {:return_1}
          double_2 = new_double {:return_2}

          subject.foobar(:anything).should == :return_1
        end

        it "dispatches the second Double with a wildcard match
          when the first double's Times Called expectation is satisfied" do
          double_1 = new_double {:return_1}
          double_2 = new_double {:return_2}

          subject.foobar(:anything)
          subject.foobar(:anything).should == :return_2
        end

        it "raises TimesCalledError when all of the doubles Times Called expectation is satisfied" do
          double_1 = new_double {:return_1}
          double_2 = new_double {:return_2}

          subject.foobar(:anything)
          subject.foobar(:anything)
          lambda do
            subject.foobar(:anything)
          end.should raise_error(Errors::TimesCalledError)
        end

        def new_double(&return_value)
          double = super
          double.definition.with_any_args.once.returns(&return_value)
          double.should be_terminal
          double
        end
      end
    end

    describe "method names with !" do
      def method_name
        :foobar!
      end

      context "when the original method uses the passed-in block" do
        it "executes the block" do
          double = new_double
          double.definition.with(1, 2) {:return_value}
          subject.foobar!(1, 2).should == :return_value
        end
      end
    end

    describe "method names with ?" do
      def method_name
        :foobar?
      end

      context "when the original method uses the passed-in block" do
        it "executes the block" do
          double = new_double
          double.definition.with(1, 2) {:return_value}
          subject.foobar?(1, 2).should == :return_value
        end
      end
    end
  end
end
