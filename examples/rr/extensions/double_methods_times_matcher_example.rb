require "examples/example_helper"

module RR
module Extensions
  describe DoubleMethods, "#any_times" do
    it_should_behave_like "RR::Extensions::DoubleMethods"
    
    it "returns an AnyTimesMatcher" do
      any_times.should == TimesCalledMatchers::AnyTimesMatcher.new
    end

    it "rr_any_times returns an AnyTimesMatcher" do
      rr_any_times.should == TimesCalledMatchers::AnyTimesMatcher.new
    end
  end
end
end
