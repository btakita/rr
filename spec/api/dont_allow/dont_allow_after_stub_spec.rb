require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe "dont_allow called after stub" do
  context "when the subject method is called" do
    it "raises a TimesCalledError" do
      subject = Object.new
      stub(subject).foobar
      dont_allow(subject).foobar
      lambda do
        subject.foobar
      end.should raise_error(RR::Errors::TimesCalledError)
    end
  end
end