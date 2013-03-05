require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module RR
  module Expectations
    describe TimesCalledExpectation do
      context "when using an AnyTimesMatcher" do
        it_should_behave_like "RR::Expectations::TimesCalledExpectation"

        describe "#verify!" do
          it "always passes" do
            stub(subject).foobar.any_number_of_times
            RR.verify

            stub(subject).foobar.any_number_of_times
            10.times {subject.foobar}
            RR.verify
          end
        end
      end
    end
  end
end