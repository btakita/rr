require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe "any_instance_of" do
  context "when passed a block" do
    it "applies to instances instantiated before the Double expection was created" do
      subject_class = Class.new
      subject = subject_class.new
      class_called = false
      any_instance_of(subject_class) do |o|
        stub(o).to_s {"Subject is stubbed"}
        stub.proxy(o).class {|klass| class_called = true; klass}
        stub(o).foobar {:baz}
      end

      subject.to_s.should == "Subject is stubbed"
      subject.class.should == subject_class
      class_called.should == true
      subject.foobar.should == :baz

      RR.reset

      subject.to_s.should_not == "Subject is stubbed"
      class_called = false
      subject.class.should == subject_class
      class_called.should == false
      subject.should_not respond_to(:baz)
    end
  end

  context "when passed a Hash" do
    it "stubs methods (key) with the value on instances instantiated before the Double expection was created" do
      subject_class = Class.new
      subject = subject_class.new
      subject.should_not respond_to(:baz)

      any_instance_of(subject_class, :to_s => "Subject is stubbed", :foobar => lambda {:baz})

      subject.to_s.should == "Subject is stubbed"
      subject.foobar.should == :baz

      RR.reset

      subject.to_s.should_not == "Subject is stubbed"
      subject.should_not respond_to(:baz)
    end
  end
end
