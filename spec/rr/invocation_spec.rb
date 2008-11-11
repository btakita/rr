require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

module RR
  describe Invocation do
    it "has arguments" do
      @invocation = Invocation.new(%w(one two))
      @invocation.args.should == %w(one two)
    end

    describe "when newly created" do
      before do
        @invocation = Invocation.new([])
      end

      it "has been called zero times" do
        @invocation.times_called.should == 0
      end

      it "was called any number of times" do
        @invocation.called?(TimesCalledMatchers::AtLeastMatcher.new(0)).should be
      end

      it "was called exactly zero times" do
        @invocation.called?(TimesCalledMatchers::IntegerMatcher.new(0)).should be
      end

      it "was not called exactly one time" do
        @invocation.called?(TimesCalledMatchers::IntegerMatcher.new(1)).should_not be
      end

      it "was not called one or more times" do
        @invocation.called?(TimesCalledMatchers::AtLeastMatcher.new(1)).should_not be
      end

      it "was called at most one time" do
        @invocation.called?(TimesCalledMatchers::AtMostMatcher.new(1)).should be
      end
    end

    describe "after being invoked twice" do
      before do
        @invocation = Invocation.new([])
        2.times { @invocation.invoke }
      end
      
      it "has been called twice" do
        @invocation.times_called.should == 2
      end

      it "was called any number of times" do
        @invocation.called?(TimesCalledMatchers::AtLeastMatcher.new(0)).should be
      end

      it "was called exactly two times" do
        @invocation.called?(TimesCalledMatchers::IntegerMatcher.new(2)).should be
      end

      it "was not called exactly one time" do
        @invocation.called?(TimesCalledMatchers::IntegerMatcher.new(1)).should_not be
      end

      it "was not called two or more times" do
        @invocation.called?(TimesCalledMatchers::AtLeastMatcher.new(2)).should be
      end

      it "was not called three or more times" do
        @invocation.called?(TimesCalledMatchers::AtLeastMatcher.new(3)).should_not be
      end

      it "was called at most two times" do
        @invocation.called?(TimesCalledMatchers::AtMostMatcher.new(2)).should be
      end

      it "was not called at most one time" do
        @invocation.called?(TimesCalledMatchers::AtMostMatcher.new(1)).should_not be
      end
    end
  end
end
