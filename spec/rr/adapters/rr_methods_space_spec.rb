require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Adapters
    describe RRMethods, " Space interactions" do
      describe RRMethods, " space example" do
        attr_reader :space, :subject_1, :subject_2, :method_name
        it_should_behave_like "RR::Adapters::RRMethods"
        before do
          @old_space = Space.instance

          @space = Space.new
          Space.instance = @space
          @subject_1 = Object.new
          @subject_2 = Object.new
          @method_name = :foobar
        end

        after do
          Space.instance = @old_space
        end
        
        describe RRMethods, "#verify" do
          it "#verify verifies and deletes the double_injections" do
            verifies_all_double_injections {verify}
          end

          it "#rr_verify verifies and deletes the double_injections" do
            verifies_all_double_injections {rr_verify}
          end

          def verifies_all_double_injections
            double_1 = space.double_injection(subject_1, method_name)
            double_1_verify_calls = 0
            double_1_reset_calls = 0
            (
            class << double_1;
              self;
            end).class_eval do
              define_method(:verify) do ||
                double_1_verify_calls += 1
              end
              define_method(:reset) do ||
                double_1_reset_calls += 1
              end
            end
            double_2 = space.double_injection(subject_2, method_name)
            double_2_verify_calls = 0
            double_2_reset_calls = 0
            (
            class << double_2;
              self;
            end).class_eval do
              define_method(:verify) do ||
                double_2_verify_calls += 1
              end
              define_method(:reset) do ||
                double_2_reset_calls += 1
              end
            end

            yield
            double_1_verify_calls.should == 1
            double_2_verify_calls.should == 1
            double_1_reset_calls.should == 1
            double_1_reset_calls.should == 1
          end
        end

        describe RRMethods, "#reset" do
          it "#reset removes the ordered doubles" do
            removes_ordered_doubles {reset}
          end

          it "#rr_reset removes the ordered doubles" do
            removes_ordered_doubles {rr_reset}
          end

          it "#reset resets all double_injections" do
            resets_all_double_injections {reset}
          end

          it "#rr_reset resets all double_injections" do
            resets_all_double_injections {rr_reset}
          end

          def removes_ordered_doubles
            double_1 = new_double(
              space.double_injection(subject_1, :foobar1),
              RR::DoubleDefinitions::DoubleDefinition.new(creator = RR::DoubleDefinitions::DoubleDefinitionCreator.new, subject_1)
            )
            double_2 = new_double(
              space.double_injection(subject_2, :foobar2),
              RR::DoubleDefinitions::DoubleDefinition.new(creator = RR::DoubleDefinitions::DoubleDefinitionCreator.new, subject_2)
            )
 
            double_1.ordered
            double_2.ordered

            space.ordered_doubles.should_not be_empty

            yield
            space.ordered_doubles.should be_empty
          end

          def resets_all_double_injections
            double_1 = space.double_injection(subject_1, method_name)
            double_1_reset_calls = 0
            (
            class << double_1;
              self;
            end).class_eval do
              define_method(:reset) do ||
                double_1_reset_calls += 1
              end
            end
            double_2 = space.double_injection(subject_2, method_name)
            double_2_reset_calls = 0
            (
            class << double_2;
              self;
            end).class_eval do
              define_method(:reset) do ||
                double_2_reset_calls += 1
              end
            end

            yield
            double_1_reset_calls.should == 1
            double_2_reset_calls.should == 1
          end
        end
      end
    end


  end
end