require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Adapters
    describe RRMethods do
      attr_reader :space, :subject_1, :subject_2, :method_name

      include_examples "Swapped Space"

      include RR::Adapters::RRMethods

      before do
        @subject_1 = Object.new
        @subject_2 = Object.new
        @method_name = :foobar
      end

      describe "#verify" do
        it "aliases #rr_verify" do
          expect(RRMethods.instance_method("verify")).to eq RRMethods.instance_method("rr_verify")
        end
      end

      describe "#rr_verify" do
        it "verifies and deletes the double_injections" do
          double_1 = ::RR::Injections::DoubleInjection.find_or_create_by_subject(subject_1, method_name)
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
          double_2 = ::RR::Injections::DoubleInjection.find_or_create_by_subject(subject_2, method_name)
          double_2_verify_calls = 0
          double_2_reset_calls = 0
          ( class << double_2; self; end).class_eval do
            define_method(:verify) do ||
              double_2_verify_calls += 1
            end
            define_method(:reset) do ||
              double_2_reset_calls += 1
            end
          end

          rr_verify
          expect(double_1_verify_calls).to eq 1
          expect(double_2_verify_calls).to eq 1
          expect(double_1_reset_calls).to eq 1
          expect(double_1_reset_calls).to eq 1
        end
      end

      describe "#reset" do
        it "aliases #rr_reset" do
          expect(RRMethods.instance_method("reset")).to eq RRMethods.instance_method("rr_reset")
        end
      end

      describe "#rr_reset" do
        it "removes the ordered doubles" do
          mock(subject_1).foobar1.ordered
          mock(subject_2).foobar2.ordered

          ::RR::Injections::DoubleInjection.instances.should_not be_empty

          rr_reset
          ::RR::Injections::DoubleInjection.instances
          expect(::RR::Injections::DoubleInjection.instances).to be_empty
        end

        it "resets all double_injections" do
          double_1 = ::RR::Injections::DoubleInjection.find_or_create_by_subject(subject_1, method_name)
          double_1_reset_calls = 0
          ( class << double_1; self; end).class_eval do
            define_method(:reset) do ||
              double_1_reset_calls += 1
            end
          end
          double_2 = ::RR::Injections::DoubleInjection.find_or_create_by_subject(subject_2, method_name)
          double_2_reset_calls = 0
          ( class << double_2; self; end).class_eval do
            define_method(:reset) do ||
              double_2_reset_calls += 1
            end
          end

          rr_reset
          expect(double_1_reset_calls).to eq 1
          expect(double_2_reset_calls).to eq 1
        end
      end
    end
  end
end
