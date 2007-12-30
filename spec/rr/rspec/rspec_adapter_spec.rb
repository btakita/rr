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

        it "resets the doubles" do
          RR::Space.double_insertion(@subject, @method_name)
          RR::Space.doubles.should_not be_empty

          @fixture.setup_mocks_for_rspec
          RR::Space.doubles.should be_empty
        end
      end

      describe "#verify_mocks_for_rspec" do
        before do
          @fixture = Object.new
          @fixture.extend Rspec

          @subject = Object.new
          @method_name = :foobar
        end

        it "verifies the doubles" do
          double_insertion = RR::Space.double_insertion(@subject, @method_name)
          scenario = RR::Space.scenario(double_insertion)

          scenario.once

          proc do
            @fixture.verify_mocks_for_rspec
          end.should raise_error(::RR::Errors::TimesCalledError)
          RR::Space.doubles.should be_empty
        end
      end

      describe "#teardown_mocks_for_rspec" do
        before do
          @fixture = Object.new
          @fixture.extend Rspec

          @subject = Object.new
          @method_name = :foobar
        end

        it "resets the doubles" do
          RR::Space.double_insertion(@subject, @method_name)
          RR::Space.doubles.should_not be_empty

          @fixture.teardown_mocks_for_rspec
          RR::Space.doubles.should be_empty
        end
      end
    end
  end
end