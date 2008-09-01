require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe Regexp do
  describe "#inspect" do
    it "returns the regexp" do
      matcher = /foo/
      matcher.inspect.should == "/foo/"
    end
  end
end
