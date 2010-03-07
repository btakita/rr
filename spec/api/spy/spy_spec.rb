require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe "spy" do
  attr_reader :subject
  before(:each) do
    @subject = Object.new
    extend RR::Adapters::RRMethods
  end

  after(:each) do
    RR.reset
  end

  it "should record all method invocations" do
    subject = Object.new

    def subject.something
    end

    def subject.something_else
    end

    spy(subject)

    subject.something
    subject.something_else
    subject.to_s

    received(subject).something.call
    received(subject).something_else.call
    received(subject).to_s.call
  end

  describe "RR recorded_calls" do
    it "should verify method calls after the fact" do
      stub(subject).pig_rabbit
      subject.pig_rabbit("bacon", "bunny meat")
      #subject.should have_received.pig_rabitt("bacon", "bunny meat")
      received(subject).pig_rabbit("bacon", "bunny meat").call
    end

    it "should verify method calls after the fact" do
      stub(subject).pig_rabbit
      lambda do
        received(subject).pig_rabbit("bacon", "bunny meat").call
      end.should raise_error(RR::Errors::SpyVerificationErrors::SpyVerificationError)
    end
  end
end
