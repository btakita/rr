require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Doubles
    describe DoubleInjection do
      before do
        @space = Space.new
        @object = Object.new
        @object.methods.should_not include(method_name.to_s)
        @double_injection = @space.double_injection(@object, method_name)
      end

      describe "normal methods" do
        def method_name
          :foobar
        end

        describe "where the double takes a block" do
          it "executes the block" do
            method_fixture = Object.new
            class << method_fixture
              def method_with_block(a, b)
                yield(a, b)
              end
            end
            double = Double.new(@double_injection)
            double.with(1, 2).implemented_by(method_fixture.method(:method_with_block))
            @object.foobar(1, 2) {|a, b| [b, a]}.should == [2, 1]
          end
        end

        describe "where there are no doubles with duplicate ArgumentExpectations" do
          it "dispatches to Double that have an exact match" do
            double1_with_exact_match = Double.new(@double_injection)
            double1_with_exact_match.with(:exact_match_1).returns {:return_1}
            double_with_no_match = Double.new(@double_injection)
            double_with_no_match.with("nothing that matches").returns {:no_match}
            double2_with_exact_match = Double.new(@double_injection)
            double2_with_exact_match.with(:exact_match_2).returns {:return_2}

            @object.foobar(:exact_match_1).should == :return_1
            @object.foobar(:exact_match_2).should == :return_2
          end

          it "dispatches to Double that have a wildcard match" do
            double_with_wildcard_match = Double.new(@double_injection)
            double_with_wildcard_match.with_any_args.returns {:wild_card_value}
            double_with_no_match = Double.new(@double_injection)
            double_with_no_match.with("nothing that matches").returns {:no_match}

            @object.foobar(:wildcard_match_1).should == :wild_card_value
            @object.foobar(:wildcard_match_2, 3).should == :wild_card_value
          end
        end

        describe "where there are doubles" do
          it "raises DoubleNotFoundError error when arguments do not match a double" do
            double_1 = Double.new(@double_injection)
            double_1.with(1, 2)

            double_2 = Double.new(@double_injection)
            double_2.with(3)

            error = nil
            begin
              @object.foobar(:arg1, :arg2)
              viotated "Error should have been raised"
            rescue Errors::DoubleNotFoundError => e
              error = e
            end
            error.message.should include("On object #<Object")
            expected_double_message_part = "unexpected method invocation in the next line followed by the expected invocations\n" <<
              "  foobar(:arg1, :arg2)\n"
              "- foobar(1, 2)\n" <<
              "- foobar(3)"
            error.message.should include(expected_double_message_part)
          end
        end

        describe "where there are Doubles with NonTerminal TimesCalledMatchers" do
          it "dispatches to Double with exact match" do
            double = double(1, 2) {:return_value}
            @object.foobar(1, 2).should == :return_value
          end

          it "matches to the last Double that was registered with an exact match" do
            double_1 = double(1, 2) {:value_1}
            double_2 = double(1, 2) {:value_2}

            @object.foobar(1, 2).should == :value_2
          end

          it "dispatches to Double with wildcard match" do
            double = double(anything) {:return_value}
            @object.foobar(:dont_care).should == :return_value
          end

          it "matches to the last Double that was registered with a wildcard match" do
            double_1 = double(anything) {:value_1}
            double_2 = double(anything) {:value_2}

            @object.foobar(:dont_care).should == :value_2
          end

          it "matches to Double with exact match Double even when a Double with wildcard match was registered later" do
            exact_double_registered_first = double(1, 2) {:exact_first}
            wildcard_double_registered_last = double(anything, anything) {:wildcard_last}

            @object.foobar(1, 2).should == :exact_first
          end

          def double(*arguments, &return_value)
            double = Double.new(@double_injection)
            double.with(*arguments).any_number_of_times.returns(&return_value)
            double.should_not be_terminal
            double
          end
        end

        describe "where there are Terminal Doubles with duplicate Exact Match ArgumentExpectations" do
          it "dispatches to Double that have an exact match" do
            double1_with_exact_match = double(:exact_match) {:return_1}

            @object.foobar(:exact_match).should == :return_1
          end

          it "dispatches to the first Double that have an exact match" do
            double1_with_exact_match = double(:exact_match) {:return_1}
            double2_with_exact_match = double(:exact_match) {:return_2}

            @object.foobar(:exact_match).should == :return_1
          end

          it "dispatches the second Double with an exact match
            when the first double's Times Called expectation is satisfied" do
            double1_with_exact_match = double(:exact_match) {:return_1}
            double2_with_exact_match = double(:exact_match) {:return_2}

            @object.foobar(:exact_match)
            @object.foobar(:exact_match).should == :return_2
          end

          it "raises TimesCalledError when all of the doubles Times Called expectation is satisfied" do
            double1_with_exact_match = double(:exact_match) {:return_1}
            double2_with_exact_match = double(:exact_match) {:return_2}

            @object.foobar(:exact_match)
            @object.foobar(:exact_match)
            lambda do
              @object.foobar(:exact_match)
            end.should raise_error(Errors::TimesCalledError)
          end

          def double(*arguments, &return_value)
            double = Double.new(@double_injection)
            double.with(*arguments).once.returns(&return_value)
            double.should be_terminal
            double
          end
        end

        describe "where there are doubles with duplicate Wildcard Match ArgumentExpectations" do
          it "dispatches to Double that have a wildcard match" do
            double_1 = double {:return_1}

            @object.foobar(:anything).should == :return_1
          end

          it "dispatches to the first Double that has a wildcard match" do
            double_1 = double {:return_1}
            double_2 = double {:return_2}

            @object.foobar(:anything).should == :return_1
          end

          it "dispatches the second Double with a wildcard match
            when the first double's Times Called expectation is satisfied" do
            double_1 = double {:return_1}
            double_2 = double {:return_2}

            @object.foobar(:anything)
            @object.foobar(:anything).should == :return_2
          end

          it "raises TimesCalledError when all of the doubles Times Called expectation is satisfied" do
            double_1 = double {:return_1}
            double_2 = double {:return_2}

            @object.foobar(:anything)
            @object.foobar(:anything)
            lambda do
              @object.foobar(:anything)
            end.should raise_error(Errors::TimesCalledError)
          end

          def double(&return_value)
            double = Double.new(@double_injection)
            double.with_any_args.once.returns(&return_value)
            double.should be_terminal
            double
          end
        end
      end

      describe "method names with !" do
        def method_name
          :foobar!
        end

        it "executes the block" do
          double = Double.new(@double_injection)
          double.with(1, 2) {:return_value}
          @object.foobar!(1, 2).should == :return_value
        end
      end

      describe "method names with ?" do
        def method_name
          :foobar?
        end

        it "executes the block" do
          double = Double.new(@double_injection)
          double.with(1, 2) {:return_value}
          @object.foobar?(1, 2).should == :return_value
        end
      end
    end
  end
end
