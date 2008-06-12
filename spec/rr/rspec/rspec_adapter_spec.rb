require "spec/spec_helper"

module RR
  module Adapters
    describe Rspec do
      describe "#setup_mocks_for_rspec" do
        before do
          @fixture = Object.new
          @fixture.extend Rspec

          @subject = Object.new
          @method_name = :foobar
        end

        it "resets the double_injections" do
          RR.double_injection(@subject, @method_name)
          RR.double_injections.should_not be_empty

          @fixture.setup_mocks_for_rspec
          RR.double_injections.should be_empty
        end
      end

      describe "#verify_mocks_for_rspec" do
        before do
          @fixture = Object.new
          @fixture.extend Rspec

          @subject = Object.new
          @method_name = :foobar
        end

        it "verifies the double_injections" do
          double_injection = RR.double_injection(@subject, @method_name)
          double = RR.double(double_injection)

          double.once

          proc do
            @fixture.verify_mocks_for_rspec
          end.should raise_error(::RR::Errors::TimesCalledError)
          RR.double_injections.should be_empty
        end
      end

      describe "#teardown_mocks_for_rspec" do
        before do
          @fixture = Object.new
          @fixture.extend Rspec

          @subject = Object.new
          @method_name = :foobar
        end

        it "resets the double_injections" do
          RR.double_injection(@subject, @method_name)
          RR.double_injections.should_not be_empty

          @fixture.teardown_mocks_for_rspec
          RR.double_injections.should be_empty
        end
      end
    end
  end
end