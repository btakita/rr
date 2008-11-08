require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Adapters
    describe Rspec do
      attr_reader :fixture, :subject, :method_name
      describe "#setup_mocks_for_rspec" do
        before do
          @fixture = Object.new
          fixture.extend Rspec

          @subject = Object.new
          @method_name = :foobar
        end

        it "resets the double_injections" do
          RR.double_injection(subject, method_name)
          RR.double_injections.should_not be_empty

          fixture.setup_mocks_for_rspec
          RR.double_injections.should be_empty
        end
      end

      describe "#verify_mocks_for_rspec" do
        before do
          @fixture = Object.new
          fixture.extend Rspec

          @subject = Object.new
          @method_name = :foobar
        end

        it "verifies the double_injections" do
          double_injection = RR.double_injection(subject, method_name)
          double = new_double(double_injection)

          double.definition.once

          lambda do
            fixture.verify_mocks_for_rspec
          end.should raise_error(::RR::Errors::TimesCalledError)
          RR.double_injections.should be_empty
        end
      end

      describe "#teardown_mocks_for_rspec" do
        before do
          @fixture = Object.new
          fixture.extend Rspec

          @subject = Object.new
          @method_name = :foobar
        end

        it "resets the double_injections" do
          RR.double_injection(subject, method_name)
          RR.double_injections.should_not be_empty

          fixture.teardown_mocks_for_rspec
          RR.double_injections.should be_empty
        end
      end
    end
  end
end