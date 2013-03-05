require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe DoubleDefinitionCreateBlankSlate do
      attr_reader :double_definition_create, :blank_slate

      include_examples "Swapped Space"

      subject { Object.new }

      before(:each) do
        @double_definition_create = DoubleDefinitionCreate.new
        double_definition_create.mock(subject)
      end

      describe ".new" do
        it "does not undefine object_id" do
          blank_slate = DoubleDefinitionCreateBlankSlate.new(double_definition_create)
          expect(blank_slate.object_id.class).to eq Fixnum
        end

        context "without block" do
          before do
            @blank_slate = DoubleDefinitionCreateBlankSlate.new(double_definition_create)
          end

          it "clears out all methods from proxy" do
            expect(stub(subject).i_should_be_a_double).to be_instance_of(DoubleDefinition)
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
              expect(subject.foobar(1, 2)).to eq :one_two
              expect(subject.foobar(1)).to eq :one
              expect(subject.foobar(:something)).to eq :default
              expect(subject.baz).to eq :baz_result
            end

            it "passes the self into the block" do
              expect(passed_in_argument.__double_definition_create__).to be_instance_of(
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
              expect(subject.foobar(1, 2)).to eq :one_two
              expect(subject.foobar(1)).to eq :one
              expect(subject.foobar(:something)).to eq :default
              expect(subject.baz).to eq :baz_result
            end

            it "evaluates the block with the context of self" do
              expect(self_value.__double_definition_create__).to be_instance_of(
                ::RR::DoubleDefinitions::DoubleDefinitionCreate
              )
            end
          end
        end
      end
    end
  end
end
