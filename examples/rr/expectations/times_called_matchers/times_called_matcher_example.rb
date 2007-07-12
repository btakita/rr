require "examples/example_helper"

module RR
module Expectations
module TimesCalledMatchers
  describe TimesCalledMatcher, "#error_message" do
    before do
      @times = 3
      @matcher = TimesCalledMatcher.new(@times)
    end

    it "has an error message" do
      @matcher.error_message(5).should == (
        "Called 5 times. Expected 3 times."
      )
    end
  end
end
end
end
