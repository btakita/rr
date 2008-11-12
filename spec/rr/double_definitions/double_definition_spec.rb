require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe DoubleDefinition do
      attr_reader :subject, :double_definition_creator, :double, :definition

      it_should_behave_like "Swapped Space"

      before do
        @subject = Object.new
        add_original_method
        @double_definition_creator = DoubleDefinitionCreator.new
        @definition = double_definition_creator.stub(subject).foobar
        @double = definition.double
      end      

      def add_original_method
        def subject.foobar(a, b)
          :original_return_value
        end
      end
      
      describe "#root_subject" do
        it "returns #double_definition_creator.root_subject" do
          definition.root_subject.should == definition.double_definition_creator.root_subject
          definition.root_subject.should == subject
        end
      end

      describe "DefinitionConstructionMethods" do
        macro("DoubleDefinition where #double_definition_creator is a Reimplementation") do
          before do
            definition.double_definition_creator.implementation_strategy.class.should == Strategies::Implementation::Reimplementation
            call_double_injection
          end
        end

        macro("DoubleDefinition where #double_definition_creator is a Proxy") do
          before do
            definition.double_definition_creator.proxy
            definition.double_definition_creator.implementation_strategy.class.should == Strategies::Implementation::Proxy
            call_double_injection
          end
        end

        describe "#with" do
          macro("#with") do
            it "returns DoubleDefinition" do
              definition.with(1).should === definition
            end

            it "sets an ArgumentEqualityExpectation" do
              definition.should be_exact_match(1, 2)
              definition.should_not be_exact_match(2)
            end
          end

          context "when not passed a block" do
            before do
              definition.with(1, 2)
              subject.foobar(1, 2)
            end

            send "#with"
          end

          context "when passed a block" do
            def call_double_injection
              actual_args = nil
              definition.with(1, 2) do |*args|
                actual_args = args
                :new_return_value
              end
              subject.foobar(1, 2)
              @return_value = subject.foobar(1, 2)
              @args = actual_args
            end

            context "when #double_definition_creator.implementation_strategy is a Reimplementation" do
              send "DoubleDefinition where #double_definition_creator is a Reimplementation"
              send "#with"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [1, 2]
                end
              end
            end

            context "when #double_definition_creator.implementation_strategy is a Proxy" do
              send "DoubleDefinition where #double_definition_creator is a Proxy"
              send "#with"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [:original_return_value]
                end
              end
            end
          end
        end

        describe "#with_any_args" do
          macro "#with_any_args" do
            it "returns DoubleDefinition" do
              definition.with_no_args.should === definition
            end

            it "sets an AnyArgumentExpectation" do
              definition.should_not be_exact_match(1)
              definition.should be_wildcard_match(1)
            end
          end

          context "when not passed a block" do
            before do
              definition.with_any_args
            end

            send "#with_any_args"
          end

          context "when passed a block" do
            def call_double_injection
              actual_args = nil
              definition.with_any_args do |*args|
                actual_args = args
                :new_return_value
              end
              @return_value = subject.foobar(1, 2)
              @args = actual_args
            end

            context "when #double_definition_creator.implementation_strategy is a Reimplementation" do
              send "DoubleDefinition where #double_definition_creator is a Reimplementation"
              send "#with_any_args"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [1, 2]
                end
              end
            end

            context "when #double_definition_creator.implementation_strategy is a Proxy" do
              send "DoubleDefinition where #double_definition_creator is a Proxy"
              send "#with_any_args"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [:original_return_value]
                end
              end
            end
          end
        end

        describe "#with_no_args" do
          macro "#with_no_args" do
            it "returns DoubleDefinition" do
              definition.with_no_args.should === definition
            end

            it "sets an ArgumentEqualityExpectation with no arguments" do
              definition.argument_expectation.should == Expectations::ArgumentEqualityExpectation.new()
            end
          end

          def add_original_method
            def subject.foobar()
              :original_return_value
            end
          end

          context "when not passed a block" do
            before do
              definition.with_no_args
            end

            send "#with_no_args"
          end

          context "when passed a block" do
            def call_double_injection
              actual_args = nil
              definition.with_no_args do |*args|
                actual_args = args
                :new_return_value
              end
              @return_value = subject.foobar
              @args = actual_args
            end

            context "when #double_definition_creator.implementation_strategy is a Reimplementation" do
              send "DoubleDefinition where #double_definition_creator is a Reimplementation"
              send "#with_no_args"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == []
                end
              end
            end

            context "when #double_definition_creator.implementation_strategy is a Proxy" do
              send "DoubleDefinition where #double_definition_creator is a Proxy"
              send "#with_no_args"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [:original_return_value]
                end
              end
            end
          end
        end

        describe "#never" do
          it "returns DoubleDefinition" do
            definition.never.should === definition
          end

          it "sets up a Times Called Expectation with 0" do
            definition.with_any_args
            definition.never
            lambda {subject.foobar}.should raise_error(Errors::TimesCalledError)
          end

          describe "#subject.method_name being called" do
            it "raises a TimesCalledError" do
              definition.with_any_args.never
              lambda {subject.foobar}.should raise_error(Errors::TimesCalledError)
            end
          end
        end

        describe "#once" do
          macro "#once" do
            it "returns DoubleDefinition" do
              definition.once.should === definition
            end

            it "sets up a Times Called Expectation with 1" do
              lambda {subject.foobar}.should raise_error(Errors::TimesCalledError)
            end
          end

          context "when not passed a block" do
            before do
              definition.with_any_args.once
              subject.foobar(1, 2)
            end

            send "#once"
          end

          context "when passed a block" do
            def call_double_injection
              actual_args = nil
              definition.with_any_args.once do |*args|
                actual_args = args
                :new_return_value
              end
              @return_value = subject.foobar(1, 2)
              @args = actual_args
            end

            context "with returns block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Reimplementation"
              send "#once"

              describe "#subject.method_name being called with any arguments" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [1, 2]
                end
              end
            end

            context "with after_call block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Proxy"
              send "#once"

              describe "#subject.method_name being called with any arguments" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [:original_return_value]
                end
              end
            end
          end
        end

        describe "#twice" do
          macro "#twice" do
            it "returns DoubleDefinition" do
              definition.twice.should === definition
            end

            it "sets up a Times Called Expectation with 2" do
              definition.twice.with_any_args
              lambda {subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
            end
          end

          context "when not passed a block" do
            before do
              definition.with_any_args.twice
              subject.foobar(1, 2)
              subject.foobar(1, 2)
            end

            send "#twice"
          end

          context "when passed a block" do
            def call_double_injection
              actual_args = nil
              definition.with_any_args.twice do |*args|
                actual_args = args
                :new_return_value
              end
              subject.foobar(1, 2)
              @return_value = subject.foobar(1, 2)
              @args = actual_args
            end

            context "with returns block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Reimplementation"
              send "#twice"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [1, 2]
                end
              end
            end

            context "with after_call block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Proxy"
              send "#twice"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [:original_return_value]
                end
              end
            end
          end
        end

        describe "#at_least" do
          macro "#at_least" do
            it "returns DoubleDefinition" do
              definition.with_any_args.at_least(2).should === definition
            end

            it "sets up a Times Called Expectation with 1" do
              definition.times_matcher.should == TimesCalledMatchers::AtLeastMatcher.new(2)
            end
          end

          context "when not passed a block" do
            before do
              definition.with_any_args.at_least(2)
              subject.foobar(1, 2)
            end

            send "#at_least"
          end

          context "when passed a block" do
            def call_double_injection
              actual_args = nil
              definition.with_any_args.at_least(2) do |*args|
                actual_args = args
                :new_return_value
              end
              subject.foobar(1, 2)
              @return_value = subject.foobar(1, 2)
              @args = actual_args
            end

            context "with returns block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Reimplementation"
              send "#at_least"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [1, 2]
                end
              end
            end

            context "with after_call block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Proxy"
              send "#at_least"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [:original_return_value]
                end
              end
            end
          end
        end

        describe "#at_most" do
          macro "#at_most" do
            it "returns DoubleDefinition" do
              definition.with_any_args.at_most(2).should === definition
            end

            it "sets up a Times Called Expectation with 1" do
              lambda do
                subject.foobar
              end.should raise_error(Errors::TimesCalledError, "foobar()\nCalled 3 times.\nExpected at most 2 times.")
            end
          end

          context "when not passed a block" do
            before do
              definition.with_any_args.at_most(2)
              subject.foobar(1, 2)
              subject.foobar(1, 2)
            end

            send "#at_most"
          end

          context "when passed a block" do
            def call_double_injection
              actual_args = nil
              definition.with_any_args.at_most(2) do |*args|
                actual_args = args
                :new_return_value
              end
              subject.foobar(1, 2)
              @return_value = subject.foobar(1, 2)
              @args = actual_args
            end

            context "with returns block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Reimplementation"
              send "#at_most"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [1, 2]
                end
              end
            end

            context "with after_call block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Proxy"
              send "#at_most"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [:original_return_value]
                end
              end
            end
          end
        end

        describe "#times" do
          macro "#times" do
            it "returns DoubleDefinition" do
              definition.times(3).should === definition
            end

            it "sets up a Times Called Expectation with passed in times" do
              lambda {subject.foobar(1, 2)}.should raise_error(Errors::TimesCalledError)
            end
          end

          context "when not passed a block" do
            before do
              definition.with(1, 2).times(3)
              subject.foobar(1, 2)
              subject.foobar(1, 2)
              subject.foobar(1, 2)
            end

            send "#times"
          end

          context "when passed a block" do
            def call_double_injection
              actual_args = nil
              definition.with(1, 2).times(3) do |*args|
                actual_args = args
                :new_return_value
              end
              subject.foobar(1, 2)
              subject.foobar(1, 2)
              @return_value = subject.foobar(1, 2)
              @args = actual_args
            end

            context "with returns block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Reimplementation"
              send "#times"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [1, 2]
                end
              end
            end

            context "with after_call block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Proxy"
              send "#times"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [:original_return_value]
                end
              end
            end
          end
        end

        describe "#any_number_of_times" do
          macro "#any_number_of_times" do
            it "returns DoubleDefinition" do
              definition.any_number_of_times.should === definition
            end

            it "sets up a Times Called Expectation with AnyTimes matcher" do
              definition.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
            end
          end

          context "when not passed a block" do
            before do
              definition.with(1, 2).any_number_of_times
              subject.foobar(1, 2)
            end

            send "#any_number_of_times"
          end

          context "when passed a block" do
            def call_double_injection
              actual_args = nil
              definition.with(1, 2).any_number_of_times do |*args|
                actual_args = args
                :new_return_value
              end
              subject.foobar(1, 2)
              @return_value = subject.foobar(1, 2)
              @args = actual_args
            end

            context "with returns block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Reimplementation"
              send "#any_number_of_times"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [1, 2]
                end
              end
            end

            context "with after_call block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Proxy"
              send "#any_number_of_times"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [:original_return_value]
                end
              end
            end
          end
        end

        describe "#ordered" do
          macro "#ordered" do
            it "adds itself to the ordered doubles list" do
              definition.ordered
              Space.instance.ordered_doubles.should include(double)
            end

            it "does not double_injection add itself" do
              definition.ordered
              Space.instance.ordered_doubles.should == [double]
            end

            it "sets ordered? to true" do
              definition.should be_ordered
            end

            context "when there is no Double" do
              it "raises a DoubleDefinitionError" do
                definition.double = nil
                lambda do
                  definition.ordered
                end.should raise_error(
                  Errors::DoubleDefinitionError,
                  "Double Definitions must have a dedicated Double to be ordered. " <<
                  "For example, using instance_of does not allow ordered to be used. " <<
                  "proxy the class's #new method instead."
                )
              end
            end
          end

          context "when not passed a block" do
            before do
              definition.with(1, 2).once.ordered
              subject.foobar(1, 2)
            end

            send "#ordered"
          end

          context "when passed a block" do
            def call_double_injection
              actual_args = nil
              definition.with(1, 2).once.ordered do |*args|
                actual_args = args
                :new_return_value
              end
              @return_value = subject.foobar(1, 2)
              @args = actual_args
            end

            context "with returns block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Reimplementation"
              send "#ordered"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [1, 2]
                end
              end
            end

            context "with after_call block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Proxy"
              send "#ordered"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [:original_return_value]
                end
              end
            end
          end
        end

        describe "#yields" do
          macro "#yields" do
            it "returns DoubleDefinition" do
              definition.yields(:baz).should === definition
            end

            context "when there is a no returns value set" do
              it "yields the passed in argument to the call block" do
                @passed_in_block_arg.should == :baz
              end
            end
          end

          context "when not passed a block" do
            before do
              definition.with(1, 2).once.yields(:baz)
              passed_in_block_arg = nil
              subject.foobar(1, 2) do |arg|
                passed_in_block_arg = arg
              end
              @passed_in_block_arg = passed_in_block_arg
            end

            send "#yields"
          end

          context "when passed a block" do
            def call_double_injection
              actual_args = nil
              definition.with(1, 2).once.yields(:baz) do |*args|
                actual_args = args
                :new_return_value
              end
              passed_in_block_arg = nil
              @return_value = subject.foobar(1, 2) do |arg|
                passed_in_block_arg = arg
              end
              @passed_in_block_arg = passed_in_block_arg

              @args = actual_args
            end

            context "with returns block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Reimplementation"
              send "#yields"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.length.should == 3
                  @args[0..1].should == [1, 2]
                  @args[2].should be_instance_of(Proc)
                end
              end
            end

            context "with after_call block_callback_strategy" do
              send "DoubleDefinition where #double_definition_creator is a Proxy"
              send "#yields"

              describe "#subject.method_name being called" do
                it "returns the return value of the block" do
                  @return_value.should == :new_return_value
                  @args.should == [:original_return_value]
                end
              end
            end
          end
        end

        describe "#after_call" do
          context "when passed a block" do
            it "returns DoubleDefinition" do
              definition.after_call {}.should === definition
            end

            describe "#subject.method_name being called" do
              it "calls the block with the return value of the implementation" do
                return_value = {:original => :value}
                definition.with_any_args.returns(return_value).after_call do |value|
                  value[:foo] = :bar
                  value
                end

                actual_value = subject.foobar
                actual_value.should === return_value
                actual_value.should == {:original => :value, :foo => :bar}
              end

              context "when the return value of the #after_call_proc is a DoubleDefinition" do
                it "returns the #subject of the DoubleDefinition" do
                  return_value = Object.new
                  inner_double_definition = nil
                  definition.with_any_args.returns(return_value).after_call do |value|
                    inner_double_definition = mock(value).inner_method(1) {:baz}
                  end

                  foobar_return_value = subject.foobar
                  foobar_return_value.should == inner_double_definition.subject
                  foobar_return_value.inner_method(1).should == :baz
                end
              end

              context "when the return value of the #after_call_proc is a DoubleDefinitionCreatorProxy" do
                it "returns the #__subject__ of the DoubleDefinitionCreatorProxy" do
                  return_value = Object.new
                  inner_double_proxy = nil
                  definition.with_any_args.returns(return_value).after_call do |value|
                    inner_double_proxy = mock(value)
                  end

                  foobar_return_value = subject.foobar
                  foobar_return_value.should == inner_double_proxy.__creator__.subject
                end
              end

              context "when the return value of the #after_call_proc is an Object" do
                it "returns the return value of the #after_call_proc" do
                  return_value = :returns_value
                  definition.with_any_args.returns(return_value).after_call do |value|
                    :after_call_proc
                  end

                  actual_value = subject.foobar
                  actual_value.should == :after_call_proc
                end
              end
            end
          end

          context "when not passed a block" do
            it "raises an ArgumentError" do
              lambda do
                definition.after_call
              end.should raise_error(ArgumentError, "after_call expects a block")
            end
          end
        end

        describe "#returns" do
          it "returns DoubleDefinition" do
            definition.returns {:baz}.should === definition
            definition.returns(:baz).should === definition
          end

          context "when passed neither an argument nor a block" do
            describe "#subject.method_name being called" do
              it "returns nil" do
                definition.with_any_args.returns
                subject.foobar.should be_nil
              end
            end
          end

          context "when passed a block" do
            describe "#subject.method_name being called" do
              it "returns the return value of the block" do
                definition.with_any_args.returns {:baz}
                subject.foobar.should == :baz
              end
            end
          end

          context "when passed an argument" do
            describe "#subject.method_name being called" do
              it "returns the passed-in argument" do
                definition.returns(:baz).with_no_args
                subject.foobar.should == :baz
              end
            end

            context "when the argument is false" do
              describe "#subject.method_name being called" do
                it "returns false" do
                  definition.returns(false).with_any_args
                  subject.foobar.should == false
                end
              end
            end
          end

          context "when passed both an argument and a block" do
            it "raises an error" do
              lambda do
                definition.returns(:baz) {:another}
              end.should raise_error(ArgumentError, "returns cannot accept both an argument and a block")
            end
          end
        end

        describe "#implemented_by" do
          it "returns the DoubleDefinition" do
            definition.implemented_by(lambda{:baz}).should === definition
          end

          context "when passed a Proc" do
            describe "#subject.method_name being called" do
              it "returns the return value of the passed-in Proc" do
                definition.implemented_by(lambda{:baz}).with_no_args
                subject.foobar.should == :baz
              end
            end
          end

          context "when passed a Method" do
            it "sets the implementation to the passed in method" do
              def subject.foobar(a, b)
                [b, a]
              end
              definition.implemented_by(subject.method(:foobar))
              subject.foobar(1, 2).should == [2, 1]
            end
          end
        end

        describe "#verbose" do
          it "sets the verbose? to true" do
            definition.should_not be_verbose
            definition.verbose
            definition.should be_verbose
          end
        end

        describe "#verify_method_signature" do
          it "sets #verify_method_signature? to true" do
            definition.verify_method_signature?.should be_false
            definition.verify_method_signature
            definition.verify_method_signature?.should be_true
          end

          it "returns self" do
            definition.verify_method_signature.should == definition
          end
        end
      end

      describe "NestedDoubleCreationMethods" do
        attr_reader :child_double_definition_creator
        after do
          RR.verify(ChildDoubleDefinitionCreator)
          RR.verify(child_double_definition_creator)
        end

        describe "#mock" do
          it "instantiates a ChildDoubleDefinitionCreator with self and delegates to its #mock method with the passed-in arguments and block" do
            child_subject = Object.new
            child_double_definition_creator = nil
            mock.proxy(ChildDoubleDefinitionCreator).new(definition) do |child_double_definition_creator|
              mock.proxy(child_double_definition_creator).mock(child_subject, :baz)
              child_double_definition_creator = child_double_definition_creator
            end

            definition.mock(child_subject, :baz)
            @child_double_definition_creator = child_double_definition_creator
          end
        end

        describe "#mock!" do
          it "instantiates a ChildDoubleDefinitionCreator with self and delegates to its #mock! method with the passed-in arguments and block" do
            child_double_definition_creator = nil
            mock.proxy(ChildDoubleDefinitionCreator).new(definition) do |child_double_definition_creator|
              mock.proxy(child_double_definition_creator).mock!(:baz)
              child_double_definition_creator = child_double_definition_creator
            end

            definition.mock!(:baz)
            @child_double_definition_creator = child_double_definition_creator
          end
        end

        describe "#stub" do
          it "instantiates a ChildDoubleDefinitionCreator with self and delegates to its #stub method with the passed-in arguments and block" do
            child_subject = Object.new
            child_double_definition_creator = nil
            mock.proxy(ChildDoubleDefinitionCreator).new(definition) do |child_double_definition_creator|
              mock.proxy(child_double_definition_creator).stub(child_subject, :baz)
              child_double_definition_creator = child_double_definition_creator
            end

            definition.stub(child_subject, :baz)
            @child_double_definition_creator = child_double_definition_creator
          end
        end

        describe "#stub!" do
          it "instantiates a ChildDoubleDefinitionCreator with self and delegates to its #stub! method with the passed-in arguments and block" do
            child_double_definition_creator = nil
            mock.proxy(ChildDoubleDefinitionCreator).new(definition) do |child_double_definition_creator|
              mock.proxy(child_double_definition_creator).stub!(:baz)
              child_double_definition_creator = child_double_definition_creator
            end

            definition.stub!(:baz)
            @child_double_definition_creator = child_double_definition_creator
          end
        end

        describe "#dont_allow" do
          it "instantiates a ChildDoubleDefinitionCreator with self and delegates to its #dont_allow method with the passed-in arguments and block" do
            child_subject = Object.new
            child_double_definition_creator = nil
            mock.proxy(ChildDoubleDefinitionCreator).new(definition) do |child_double_definition_creator|
              mock.proxy(child_double_definition_creator).dont_allow(child_subject, :baz)
              child_double_definition_creator = child_double_definition_creator
            end

            definition.dont_allow(child_subject, :baz)
            @child_double_definition_creator = child_double_definition_creator
          end
        end

        describe "#dont_allow!" do
          it "instantiates a ChildDoubleDefinitionCreator with self and delegates to its #dont_allow! method with the passed-in arguments and block" do
            child_double_definition_creator = nil
            mock.proxy(ChildDoubleDefinitionCreator).new(definition) do |child_double_definition_creator|
              mock.proxy(child_double_definition_creator).dont_allow!(:baz)
              child_double_definition_creator = child_double_definition_creator
            end

            definition.dont_allow!(:baz)
            @child_double_definition_creator = child_double_definition_creator
          end
        end

        describe "#proxy" do
          it "instantiates a ChildDoubleDefinitionCreator with self and delegates to its #proxy method with the passed-in arguments and block" do
            child_subject = Object.new
            child_double_definition_creator = nil
            mock.proxy(ChildDoubleDefinitionCreator).new(definition) do |child_double_definition_creator|
              mock.proxy(child_double_definition_creator).proxy(DoubleDefinitionCreator::NO_SUBJECT, nil)
              child_double_definition_creator = child_double_definition_creator
            end

            definition.proxy.mock(child_subject)
            @child_double_definition_creator = child_double_definition_creator
          end
        end

        describe "#proxy!" do
          it "raises a DoubleDefinitionError" do
            lambda do
              definition.proxy!(:baz)
            end.should raise_error(Errors::DoubleDefinitionError)
          end
        end

        describe "#strong" do
          it "instantiates a ChildDoubleDefinitionCreator with self and delegates to its #strong method with the passed-in arguments and block" do
            child_subject = Object.new
            child_double_definition_creator = nil
            mock.proxy(ChildDoubleDefinitionCreator).new(definition) do |child_double_definition_creator|
              mock.proxy(child_double_definition_creator).strong(DoubleDefinitionCreator::NO_SUBJECT, nil)
              child_double_definition_creator = child_double_definition_creator
            end

            definition.strong.mock(child_subject)
            @child_double_definition_creator = child_double_definition_creator
          end
        end

        describe "#strong!" do
          it "raises a DoubleDefinitionError" do
            lambda do
              definition.strong!(:baz)
            end.should raise_error(Errors::DoubleDefinitionError)
          end
        end
      end

      describe "StateQueryMethods" do
        describe "#ordered?" do
          it "defaults to false" do
            definition.should_not be_ordered
          end
        end

        describe "#exact_match?" do
          context "when no argument_expectation set" do
            it "raises a DoubleDefinitionError" do
              definition.argument_expectation = nil
              lambda do
                definition.exact_match?
              end.should raise_error(Errors::DoubleDefinitionError)
            end
          end

          context "when arguments are not an exact match" do
            it "returns false" do
              definition.with(1, 2, 3)
              definition.should_not be_exact_match(1, 2)
              definition.should_not be_exact_match(1)
              definition.should_not be_exact_match()
              definition.should_not be_exact_match("does not match")
            end
          end

          context "when arguments are an exact match" do
            it "returns true" do
              definition.with(1, 2, 3)
              definition.should be_exact_match(1, 2, 3)
            end
          end
        end

        describe "#wildcard_match?" do
          context "when no #argument_expectation is set" do
            it "raises a DoubleDefinitionError" do
              definition.argument_expectation = nil
              lambda do
                definition.wildcard_match?
              end.should raise_error(Errors::DoubleDefinitionError)
            end
          end

          context "when arguments are an exact match" do
            it "returns true" do
              definition.with(1, 2, 3)
              definition.should be_wildcard_match(1, 2, 3)
              definition.should_not be_wildcard_match(1, 2)
              definition.should_not be_wildcard_match(1)
              definition.should_not be_wildcard_match()
              definition.should_not be_wildcard_match("does not match")
            end
          end

          context "when with_any_args" do
            it "returns true" do
              definition.with_any_args

              definition.should be_wildcard_match(1, 2, 3)
              definition.should be_wildcard_match(1, 2)
              definition.should be_wildcard_match(1)
              definition.should be_wildcard_match()
              definition.should be_wildcard_match("does not match")
            end
          end
        end

        describe "#terminal?" do
          context "when times_matcher's terminal? is true" do
            it "returns true" do
              definition.once
              definition.times_matcher.should be_terminal
              definition.should be_terminal
            end
          end

          context "when times_matcher's terminal? is false" do
            it "returns false" do
              definition.any_number_of_times
              definition.times_matcher.should_not be_terminal
              definition.should_not be_terminal
            end
          end

          context "when there is not times_matcher" do
            it "raises a DoubleDefinitionError" do
              definition.times_matcher = nil
              lambda do
                definition.terminal?
              end.should raise_error(Errors::DoubleDefinitionError)
            end
          end
        end

        describe "#expected_arguments" do
          context "when there is a argument expectation" do
            it "returns argument expectation's expected_arguments" do
              definition.with(1, 2)
              definition.expected_arguments.should == [1, 2]
            end
          end

          context "when there is no argument expectation" do
            it "returns an empty array" do
              definition.argument_expectation = nil
              definition.expected_arguments.should == []
            end
          end
        end
      end
    end
  end
end