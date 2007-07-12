require "examples/example_helper"

module RR
module Expectations
describe TimesCalledExpectation, ".new" do
  it "doesn't accept both an argument and a block" do
    proc do
      TimesCalledExpectation.new(2) {|value| value == 2}
    end.should raise_error(ArgumentError, "Cannot pass in both an argument and a block")
  end
end
end
end
