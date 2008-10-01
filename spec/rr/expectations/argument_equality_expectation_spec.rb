require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Expectations
    describe ArgumentEqualityExpectation do
      attr_reader :expectation
      before do
        @expectation = ArgumentEqualityExpectation.new(1, 2, 3)
      end

      describe "#expected_arguments" do
        it "returns the passed in expected_arguments" do
          expectation.expected_arguments.should == [1, 2, 3]
        end
      end

      describe "==" do
        it "returns true when passed in expected_arguments are equal" do
          expectation.should == ArgumentEqualityExpectation.new(1, 2, 3)
        end

        it "returns false when passed in expected_arguments are not equal" do
          expectation.should_not == ArgumentEqualityExpectation.new(1, 2)
          expectation.should_not == ArgumentEqualityExpectation.new(1)
          expectation.should_not == ArgumentEqualityExpectation.new(:something)
          expectation.should_not == ArgumentEqualityExpectation.new()
        end
      end

      describe "#exact_match?" do
        context "when all arguments exactly match" do
          it "returns true" do
            expectation.should be_exact_match(1, 2, 3)
          end
        end

        context "when all arguments do not exactly match" do
          it "returns false" do
            expectation.should_not be_exact_match(1, 2)
            expectation.should_not be_exact_match(1)
            expectation.should_not be_exact_match()
            expectation.should_not be_exact_match("does not match")
          end
        end
      end

      describe "#wildcard_match?" do
        context "when not an exact match" do
          it "returns false" do
            expectation = ArgumentEqualityExpectation.new(1)
            expectation.should_not be_wildcard_match(1, 2, 3)
            expectation.should_not be_wildcard_match("whatever")
            expectation.should_not be_wildcard_match("whatever", "else")
          end
        end

        context "when an exact match" do
          it "returns true" do
            expectation = ArgumentEqualityExpectation.new(1, 2)
            expectation.should be_wildcard_match(1, 2)
            expectation.should_not be_wildcard_match(1)
            expectation.should_not be_wildcard_match("whatever", "else")
          end
        end

        context "when not passed correct number of arguments" do
          it "returns false" do
            expectation.should_not be_wildcard_match()
            expectation.should_not be_wildcard_match(Object.new, Object.new)
          end
        end
      end

      describe "Functional spec" do
        class ArgumentEqualityFunctionalFixture
          attr_reader :arg1, :arg2
          def initialize(arg1, arg2)
            @arg1, @arg2 = arg1, arg2
          end

          def ==(other)
            arg1 == (other.arg1) &&
            arg2 == (other.arg2)
          end

          def eql?(other)
            arg1.eql?(other.arg1) &&
            arg2.eql?(other.arg2)
          end
        end

        before(:each) do
          @predicate1 = 'first' # these should be mocks, waiting on rr bug fix
          @predicate2 = 'second'
          @predicate3 = 'third'
        end

        describe "when mock.proxy ==" do
          it "does not have infinite recursion" do
            mock.proxy(@predicate1) == @predicate1
            mock.proxy(@predicate2) == @predicate2
            ArgumentEqualityFunctionalFixture.new(@predicate1, @predicate2).should == ArgumentEqualityFunctionalFixture.new(@predicate1, @predicate2)

            mock.proxy(@predicate1) == @predicate1
            mock.proxy(@predicate2) == @predicate3
            ArgumentEqualityFunctionalFixture.new(@predicate1, @predicate2).should_not == ArgumentEqualityFunctionalFixture.new(@predicate1, @predicate3)
          end

          it "matches Hashes properly (using ==)" do
            mock.proxy(@predicate1) == {:foo => :bar}
            @predicate1 == {:foo => :bar}
          end
        end

        describe "when mock.proxy .eql?" do
          it "does not have infinite recursion" do
            mock.proxy(@predicate1).eql? @predicate1
            mock.proxy(@predicate2).eql? @predicate2
            ArgumentEqualityFunctionalFixture.new(@predicate1, @predicate2).should be_eql(ArgumentEqualityFunctionalFixture.new(@predicate1, @predicate2))

            mock.proxy(@predicate1).eql? @predicate1
            mock.proxy(@predicate2).eql? @predicate3
            ArgumentEqualityFunctionalFixture.new(@predicate1, @predicate2).should_not be_eql(ArgumentEqualityFunctionalFixture.new(@predicate1, @predicate3))
          end

          it "matches Hashes properly (using ==)" do
            mock.proxy(@predicate1).eql?({:foo => :bar})
            @predicate1.eql?({:foo => :bar})
          end
        end

      end
    end
  end
end
