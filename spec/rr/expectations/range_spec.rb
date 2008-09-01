require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe Range do
  describe "#inspect" do
    it "returns the range" do
      matcher = 2..3
      matcher.inspect.should == "2..3"
    end
  end
end
