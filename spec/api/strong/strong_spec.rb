require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

class StrongSpecFixture
  def method_with_no_arguments
  end

  def method_with_one_argument(string)
  end

  def method_with_two_arguments(string, integer)
  end

  def method_with_three_arguments_including_varargs(string, integer, *args)
  end

  def method_with_varargs(*args)
  end
end

describe "strong" do
  attr_reader :subject
  before(:each) do
    @subject = Object.new
    extend RR::Adapters::RRMethods
  end

  after(:each) do
    RR.reset
  end

  context "when the method does not exist" do
    it "raises an exception" do
      lambda do
        strong.stub(StrongSpecFixture.new).something
      end.should raise_error(RR::Errors::SubjectDoesNotImplementMethodError)
    end
  end

  context "when the method exists with no arguments" do
    it "does not raise an exception" do
      strong.stub(StrongSpecFixture.new).method_with_no_arguments
    end
  end

  context "when the method has a different arity" do
    it "raises an exception" do
      lambda do
        strong.stub(StrongSpecFixture.new).method_with_one_argument
      end.should raise_error(RR::Errors::SubjectHasDifferentArityError)
    end
  end

  context "when the method has accepts a variable number of arguments" do
    it "does not raise an exception" do
      strong.stub(StrongSpecFixture.new).method_with_varargs
    end
  end

  context "when the method does not provide the required parameters before varargs" do
    it "raises an exception" do
      lambda do
        strong.stub(StrongSpecFixture.new).method_with_three_arguments_including_varargs
      end.should raise_error(RR::Errors::SubjectHasDifferentArityError)
    end
  end

  context "when the minimum number of parameters are provided" do
    it "does not raise an exception" do
      strong.stub(StrongSpecFixture.new).method_with_three_arguments_including_varargs("one", 2)
    end
  end

  context "when using instance_of and the method does not exist" do
    it "raises an exception" do
      lambda do
        strong.stub.instance_of(StrongSpecFixture).something
        StrongSpecFixture.new
      end.should raise_error(RR::Errors::SubjectDoesNotImplementMethodError)
    end
  end

  context "when using instance_of and the method does exist" do
    it "does not raise an exception" do
      strong.stub.instance_of(StrongSpecFixture).method_with_no_arguments
    end
  end
end
