require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

class TestObject
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

describe RR::Double do
  describe "strong" do
    it "should raise an exception if a non existent method is stubbed" do
      lambda do 
        strong.stub(TestObject.new).something
      end.should raise_error(RR::Errors::SubjectDoesNotImplementMethodError)
    end
    
    it "should not raise an exception if the method exists" do
      strong.stub(TestObject.new).method_with_no_arguments
    end
    
    it "should still return the block value" do
      test_object = TestObject.new
      strong.stub(test_object).method_with_no_arguments {5}
      test_object.method_with_no_arguments.should == 5
    end
    
    it "should raise an exception if the method has a different arity" do
      lambda do 
        strong.stub(TestObject.new).method_with_one_argument
      end.should raise_error(RR::Errors::SubjectHasDifferentArityError)
    end
    
    it "should not raise an exception if the method just has varargs" do
      strong.stub(TestObject.new).method_with_varargs
    end
    
    it "should raise an exception if the method does not provide the required parameters before varargs" do
      lambda do 
        strong.stub(TestObject.new).method_with_three_arguments_including_varargs
      end.should raise_error(RR::Errors::SubjectHasDifferentArityError)
    end
    
    it "should not raise an exception if the minimum number of parameters are provided" do
      strong.stub(TestObject.new).method_with_three_arguments_including_varargs("one", 2)
    end
    
    it "should raise an exception when using instance_of and the method does not exist" do
      lambda do
        strong.stub.instance_of(TestObject).something
        TestObject.new
      end.should raise_error(RR::Errors::SubjectDoesNotImplementMethodError)
    end
    
    it "should not raise an exception when using instance_of and the method does exist" do
      strong.stub.instance_of(TestObject).method_with_no_arguments
    end
  end
end