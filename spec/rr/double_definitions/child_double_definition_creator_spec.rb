require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe ChildDoubleDefinitionCreator do
      attr_reader :parent_subject, :parent_double_definition_creator, :parent_double_definition, :child_double_definition_creator
      it_should_behave_like "Swapped Space"
      before(:each) do
        @parent_subject = Object.new
        @parent_double_definition_creator = DoubleDefinitionCreator.new
        @parent_double_definition = DoubleDefinition.new(parent_double_definition_creator, parent_subject)
        @child_double_definition_creator = ChildDoubleDefinitionCreator.new(parent_double_definition)
      end

      describe "#root_subject" do
        it "returns the #parent_double_definition.root_subject" do
          child_subject = Object.new
          parent_double_definition_creator.stub(parent_subject)
          child_double_definition_creator.stub(child_subject)
          child_double_definition_creator.root_subject.should == parent_subject
        end
      end      
      
      describe "Strategies::Verification definitions" do
        describe "methods without !" do
          attr_reader :child_subject
          before do
            @child_subject = Object.new
          end

          describe "#mock" do
            context "when passed a subject" do
              it "sets #parent_double_definition.implementation to a Proc returning the passed-in subject" do
                parent_double_definition.implementation.should be_nil
                child_double_definition_creator.mock(child_subject)
                parent_double_definition.implementation.call.should == child_subject
              end
            end
          end

          describe "#stub" do
            context "when passed a subject" do
              it "sets #parent_double_definition.implementation to a Proc returning the passed-in subject" do
                parent_double_definition.implementation.should be_nil
                child_double_definition_creator.stub(child_subject)
                parent_double_definition.implementation.call.should == child_subject
              end
            end
          end

          describe "#dont_allow" do
            context "when passed a subject" do
              it "sets #parent_double_definition.implementation to a Proc returning the passed-in subject" do
                parent_double_definition.implementation.should be_nil
                child_double_definition_creator.dont_allow(child_subject)
                parent_double_definition.implementation.call.should == child_subject
              end
            end
          end
        end

        describe "methods with !" do
          describe "#mock!" do
            it "sets #parent_double_definition.implementation to a Proc returning the #subject" do
              parent_double_definition.implementation.should be_nil
              child_subject = child_double_definition_creator.mock!.__creator__.subject
              parent_double_definition.implementation.call.should == child_subject
            end
          end

          describe "#stub!" do
            it "sets #parent_double_definition.implementation to a Proc returning the #subject" do
              parent_double_definition.implementation.should be_nil
              child_subject = child_double_definition_creator.stub!.__creator__.subject
              parent_double_definition.implementation.call.should == child_subject
            end
          end

          describe "#dont_allow!" do
            it "sets #parent_double_definition.implementation to a Proc returning the #subject" do
              parent_double_definition.implementation.should be_nil
              child_subject = child_double_definition_creator.dont_allow!.__creator__.subject
              parent_double_definition.implementation.call.should == child_subject
            end
          end
        end
      end

      describe "Strategies::Scope definitions" do
        describe "methods without !" do
          describe "#instance_of" do
            it "raises a NoMethodError" do
              lambda do
                child_double_definition_creator.instance_of
              end.should raise_error(NoMethodError)
            end
          end
        end

        describe "methods with !" do
          describe "#instance_of!" do
            it "raises a NoMethodError" do
              lambda do
                child_double_definition_creator.instance_of!
              end.should raise_error(NoMethodError)
            end
          end
        end
      end
    end
  end
end