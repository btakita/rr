require File.expand_path("#{File.dirname(__FILE__)}/spec_helper")

class Alpha
  def bob
  end
end

describe RR::RecordedCalls do
  attr_reader :subject, :recorded_calls
  before(:each) do
    @subject = Object.new
    extend RR::Adapters::RRMethods
    stub(subject).foobar
    @recorded_calls = RR::RecordedCalls.new([[subject,:foobar,[1,2],nil]])
  end
  
  describe "spy" do
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
  end
  
    
  it "should be able to verify calls to methods defined on Object" do
    stub(subject).to_s
    subject.to_s
    received(subject).to_s.call
  end

  it "should be able to call methods used by rr" do
    stub(subject).times
    subject.times
    received(subject).times.call
  end
  
  it "should verify method calls after the fact" do
    stub(subject).pig_rabbit
    subject.pig_rabbit("bacon", "bunny meat")
    #subject.should have_received.pig_rabitt("bacon", "bunny meat")
    received(subject).pig_rabbit("bacon", "bunny meat").call
  end
  
  it "should match when there is an exact match" do
    subject.foobar(1,2)
    received(subject).foobar(1,2).call
  end

  it "should match when there is an exact match with a times matcher" do
    subject.foobar(1,2)
    received(subject).foobar(1,2).once.call
    subject.foobar(1,2)
  end

  it "should match when there is an at least matcher" do
    subject.foobar(1,2)
    subject.foobar(1,2)
    subject.foobar(1,2)
    received(subject).foobar(1,2).at_least(2).call
  end

  it "should raise an error when the number of times doesn't match" do
    subject.foobar(1,2)
    lambda do
      received(subject).foobar(1,2).twice.call
    end.should raise_error(RR::Errors::SpyVerificationError)    
  end
  
  it "should raise an error when the order is incorrect" do
    subject.foobar(3,4)
    subject.foobar(1,2)
    lambda do
      received(subject).foobar(1,2).ordered.call
      received(subject).foobar(3,4).ordered.call
    end.should raise_error(RR::Errors::SpyVerificationError)
  end
  
  it "should not raise an error when the order is correct" do
    subject.foobar(1,2)
    subject.foobar(1,2)
    subject.foobar(3,4)
    received(subject).foobar(1,2).ordered.call
    received(subject).foobar(3,4).ordered.call
  end

  it "should match when there is an wildcard match" do
    subject.foobar(1,2)
    received(subject).foobar(1,is_a(Fixnum)).call
  end
  
  it "should not match when there is neither an exact nor wildcard match" do
    subject.foobar(1,2)
    received(subject).foobar(1,is_a(Fixnum)).call
    lambda do
      received(subject).foobar(1,is_a(String)).call
    end.should raise_error(RR::Errors::SpyVerificationError)
  end
  
  it "should raise an error when the subject doesn't match" do
    subject.foobar(1,2)
    @wrong_subject = Object.new
    lambda do
      received(@wrong_subject).foobar(1,2).once.call
    end.should raise_error(RR::Errors::SpyVerificationError)    
  end
end