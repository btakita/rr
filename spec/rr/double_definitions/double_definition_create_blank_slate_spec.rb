require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe DoubleDefinitionCreateBlankSlate do
      attr_reader :subject, :double_definition_create, :blank_slate
      it_should_behave_like "Swapped Space"

      before(:each) do
        @subject = Object.new
        @double_definition_create = DoubleDefinitionCreate.new
        double_definition_create.mock(subject)
      end

      describe ".new" do
        it "does not undefine object_id" do
          blank_slate = DoubleDefinitionCreateBlankSlate.new(double_definition_create)
          blank_slate.object_id.class.should == Fixnum
        end

        context "without block" do
          before do
            @blank_slate = DoubleDefinitionCreateBlankSlate.new(double_definition_create)
          end

          it "clears out all methods from proxy" do
            stub(subject).i_should_be_a_double.should be_instance_of(DoubleDefinition)
          end
        end

        context "when passed a block" do
          context "when the block has an arity of 1" do
            attr_reader :passed_in_argument
            before do
              passed_in_argument = nil
              stub(subject) do |b|
                passed_in_argument = b
                b.foobar(1, 2) {:one_two}
                b.foobar(1) {:one}
                b.foobar.with_any_args {:default}
                b.baz() {:baz_result}
              end
              @passed_in_argument = passed_in_argument
            end

            it "creates double_injections" do
              subject.foobar(1, 2).should == :one_two
              subject.foobar(1).should == :one
              subject.foobar(:something).should == :default
              subject.baz.should == :baz_result
            end

            it "passes the self into the block" do
              passed_in_argument.__double_definition_create__.should be_instance_of(
                ::RR::DoubleDefinitions::DoubleDefinitionCreate
              )
            end
          end

          context "when the block has an arity of 0" do
            attr_reader :self_value
            before do
              self_value = nil
              stub(subject) do ||
                self_value = self
                foobar(1, 2) {:one_two}
                foobar(1) {:one}
                foobar.with_any_args {:default}
                baz() {:baz_result}
              end
              @self_value = self_value
            end

            it "creates double_injections" do
              subject.foobar(1, 2).should == :one_two
              subject.foobar(1).should == :one
              subject.foobar(:something).should == :default
              subject.baz.should == :baz_result
            end

            it "evaluates the block with the context of self" do
              self_value.__double_definition_create__.should be_instance_of(
                ::RR::DoubleDefinitions::DoubleDefinitionCreate
              )
            end
          end
        end
      end
    end    
  end
end