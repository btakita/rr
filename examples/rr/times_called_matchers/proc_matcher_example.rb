require "examples/example_helper"

module RR
module TimesCalledMatchers
  describe ProcMatcher, "#possible_match?" do
    before do
      @times = proc {|other| other == 3}
      @matcher = ProcMatcher.new(@times)
    end

    it "always returns true" do
      @matcher.should be_possible_match(2)
      @matcher.should be_possible_match(3)
      @matcher.should be_possible_match(10)
    end
  end

  describe ProcMatcher, "#matches?" do
    before do
      @times = proc {|other| other == 3}
      @matcher = ProcMatcher.new(@times)
    end

    it "returns false when proc returns false" do
      @times.call(2).should be_false
      @matcher.should_not be_matches(2)
    end

    it "returns true when proc returns true" do
      @times.call(3).should be_true
      @matcher.should be_matches(3)
    end
  end

  describe ProcMatcher, "#attempt?" do
    before do
      @times = proc {|other| other == 3}
      @matcher = ProcMatcher.new(@times)
    end

    it "always returns true" do
      @matcher.should be_attempt(2)
      @matcher.should be_attempt(3)
      @matcher.should be_attempt(10)
    end
  end

  describe ProcMatcher, "#error_message" do
    before do
      @times = proc {|other| other == 3}
      @matcher = ProcMatcher.new(@times)
    end

    it "has an error message" do
      @matcher.error_message(1).should =~
        /Called 1 time. Expected #<Proc.*> times./
    end
  end
end
end
