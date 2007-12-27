require "spec/example_helper"

module RR
module TimesCalledMatchers
  describe ProcMatcher, :shared => true do
    before do
      @times = proc {|other| other == 3}
      @matcher = ProcMatcher.new(@times)
    end
  end

  describe TimesCalledMatcher, ".create when passed a ProcMatcher" do
    it "returns the passed in argument" do
      matcher = ProcMatcher.new(proc {|other| other == 5})
      TimesCalledMatcher.create(matcher).should === matcher
    end
  end

  describe TimesCalledMatcher, ".create when passed a Integer" do
    it "returns ProcMatcher" do
      value = proc {|other| other == 5}
      TimesCalledMatcher.create(value).should == ProcMatcher.new(value)
    end
  end

  describe ProcMatcher, "#possible_match?" do
    it_should_behave_like "RR::TimesCalledMatchers::ProcMatcher"

    it "always returns true" do
      @matcher.should be_possible_match(2)
      @matcher.should be_possible_match(3)
      @matcher.should be_possible_match(10)
    end
  end

  describe ProcMatcher, "#matches?" do
    it_should_behave_like "RR::TimesCalledMatchers::ProcMatcher"

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
    it_should_behave_like "RR::TimesCalledMatchers::ProcMatcher"

    it "always returns true" do
      @matcher.should be_attempt(2)
      @matcher.should be_attempt(3)
      @matcher.should be_attempt(10)
    end
  end

  describe ProcMatcher, "#terminal?" do
    it_should_behave_like "RR::TimesCalledMatchers::ProcMatcher"

    it "returns false" do
      @matcher.should_not be_terminal
    end
  end

  describe ProcMatcher, "#error_message" do
    it_should_behave_like "RR::TimesCalledMatchers::ProcMatcher"

    it "has an error message" do
      @matcher.error_message(1).should =~
        /Called 1 time.\nExpected #<Proc.*> times./
    end
  end
end
end
