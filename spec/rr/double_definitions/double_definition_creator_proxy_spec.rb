require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe DoubleDefinitionCreatorProxy do
      attr_reader :subject, :creator, :the_proxy
      it_should_behave_like "Swapped Space"

      before(:each) do
        @subject = Object.new
        @creator = DoubleDefinitionCreator.new
        creator.mock(subject)
      end

      macro("initializes proxy with passed in creator") do
        it "initializes proxy with passed in creator" do
          class << the_proxy
            attr_reader :creator
          end
          the_proxy.creator.should === creator
        end
      end

      describe ".new" do
        it "does not undefine object_id" do
          the_proxy = DoubleDefinitionCreatorProxy.new(creator)
          the_proxy.object_id.class.should == Fixnum
        end

        context "without block" do
          before do
            @the_proxy = DoubleDefinitionCreatorProxy.new(creator)
          end

          send "initializes proxy with passed in creator"

          it "clears out all methods from proxy" do
            proxy_subclass = Class.new(DoubleDefinitionCreatorProxy) do
              def i_should_be_a_double
              end
            end
            proxy_subclass.instance_methods.map {|m| m.to_s}.should include('i_should_be_a_double')

            proxy = proxy_subclass.new(creator)
            proxy.i_should_be_a_double.should be_instance_of(DoubleDefinition)
          end
        end

        context "when passed a block" do
          macro("calls the block to define the Doubles") do
            send "initializes proxy with passed in creator"

            it "creates double_injections" do
              subject.foobar(1, 2).should == :one_two
              subject.foobar(1).should == :one
              subject.foobar(:something).should == :default
              subject.baz.should == :baz_result
            end

            it "clears out all methods from proxy" do
              proxy_subclass = Class.new(DoubleDefinitionCreatorProxy) do
                def i_should_be_a_double
                end
              end
              proxy_subclass.instance_methods.map {|m| m.to_s}.should include('i_should_be_a_double')

              proxy_subclass.new(creator) do |m|
                m.i_should_be_a_double.should be_instance_of(DoubleDefinition)
              end
            end
          end

          context "when the block has an arity of 1" do
            attr_reader :passed_in_argument
            before do
              passed_in_argument = nil
              block = lambda do |b|
                passed_in_argument = b
                b.foobar(1, 2) {:one_two}
                b.foobar(1) {:one}
                b.foobar.with_any_args {:default}
                b.baz() {:baz_result}
              end
              block.arity.should == 1

              @the_proxy = DoubleDefinitionCreatorProxy.new(creator, &block)
              @passed_in_argument = passed_in_argument
            end

            send("calls the block to define the Doubles")

            it "passes the self into the block" do
              passed_in_argument.__creator__.should == creator
            end
          end

          context "when the block has an arity of -1" do
            attr_reader :self_value, :passed_in_arguments
            before do
              self_value = nil
              passed_in_arguments = nil
              block = lambda do |*args|
                self_value = self
                passed_in_arguments = args
                args[0].foobar(1, 2) {:one_two}
                args[0].foobar(1) {:one}
                args[0].foobar.with_any_args {:default}
                args[0].baz() {:baz_result}
              end
              block.arity.should == -1

              @the_proxy = DoubleDefinitionCreatorProxy.new(creator, &block)
              @self_value = self_value
              @passed_in_arguments = passed_in_arguments
            end

            send("calls the block to define the Doubles")

            it "passes the self into the block" do
              passed_in_arguments.map {|a| a.__creator__}.should == [creator]
            end

            it "evaluates the block with the context of self" do
              self_value.__creator__.should == creator
            end
          end

          context "when the block has an arity of 0" do
            attr_reader :self_value
            before do
              self_value = nil
              block = lambda do ||
                self_value = self
                foobar(1, 2) {:one_two}
                foobar(1) {:one}
                foobar.with_any_args {:default}
                baz() {:baz_result}
              end
              block.arity.should == 0

              @the_proxy = DoubleDefinitionCreatorProxy.new(creator, &block)
              @self_value = self_value
            end

            send("calls the block to define the Doubles")

            it "evaluates the block with the context of self" do
              self_value.__creator__.should == creator
            end
          end
        end
      end
    end    
  end
end