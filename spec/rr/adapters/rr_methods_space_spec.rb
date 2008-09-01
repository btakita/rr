require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Adapters
    describe RRMethods, " Space interactions" do
      describe RRMethods, " space example" do
        it_should_behave_like "RR::Adapters::RRMethods"
        before do
          @old_space = Space.instance

          @space = Space.new
          Space.instance = @space
          @object1 = Object.new
          @object2 = Object.new
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
            double1 = @space.double_injection(@object1, @method_name)
            double1_verify_calls = 0
            double1_reset_calls = 0
            (
            class << double1;
              self;
            end).class_eval do
              define_method(:verify) do ||
                double1_verify_calls += 1
              end
              define_method(:reset) do ||
                double1_reset_calls += 1
              end
            end
            double2 = @space.double_injection(@object2, @method_name)
            double2_verify_calls = 0
            double2_reset_calls = 0
            (
            class << double2;
              self;
            end).class_eval do
              define_method(:verify) do ||
                double2_verify_calls += 1
              end
              define_method(:reset) do ||
                double2_reset_calls += 1
              end
            end

            yield
            double1_verify_calls.should == 1
            double2_verify_calls.should == 1
            double1_reset_calls.should == 1
            double1_reset_calls.should == 1
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
            double1 = @space.double_injection(@object1, :foobar1)
            double2 = @space.double_injection(@object1, :foobar2)

            double1 = Double.new(double1)
            double2 = Double.new(double2)

            double1.ordered
            double2.ordered

            @space.ordered_doubles.should_not be_empty

            yield
            @space.ordered_doubles.should be_empty
          end

          def resets_all_double_injections
            double1 = @space.double_injection(@object1, @method_name)
            double1_reset_calls = 0
            (
            class << double1;
              self;
            end).class_eval do
              define_method(:reset) do ||
                double1_reset_calls += 1
              end
            end
            double2 = @space.double_injection(@object2, @method_name)
            double2_reset_calls = 0
            (
            class << double2;
              self;
            end).class_eval do
              define_method(:reset) do ||
                double2_reset_calls += 1
              end
            end

            yield
            double1_reset_calls.should == 1
            double2_reset_calls.should == 1
          end
        end
      end
    end


  end
end