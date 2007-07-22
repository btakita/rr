require "examples/example_helper"

module RR
module Adapters
  describe Rspec, "#setup_mocks_for_rspec" do
    before do
      @fixture = Object.new
      @fixture.extend Rspec

      @subject = Object.new
      @method_name = :foobar
    end

    it "resets the doubles" do
      RR::Space.instance.double(@subject, @method_name)
      RR::Space.instance.doubles.should_not be_empty

      @fixture.setup_mocks_for_rspec
      RR::Space.instance.doubles.should be_empty
    end
  end

  describe Rspec, "#verify_mocks_for_rspec" do
    before do
      @fixture = Object.new
      @fixture.extend Rspec

      @subject = Object.new
      @method_name = :foobar
    end

    it "verifies the doubles" do
      double = RR::Space.instance.double(@subject, @method_name)
      scenario = RR::Space.instance.scenario(double)

      scenario.once

      proc do
        @fixture.verify_mocks_for_rspec
      end.should raise_error(::RR::Errors::TimesCalledError)
      RR::Space.instance.doubles.should be_empty
    end
  end

  describe Rspec, "#teardown_mocks_for_rspec" do
    before do
      @fixture = Object.new
      @fixture.extend Rspec

      @subject = Object.new
      @method_name = :foobar
    end

    it "resets the doubles" do
      RR::Space.instance.double(@subject, @method_name)
      RR::Space.instance.doubles.should_not be_empty

      @fixture.teardown_mocks_for_rspec
      RR::Space.instance.doubles.should be_empty
    end
  end
end
end