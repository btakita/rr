require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe "new_instance_of" do
  context "when passed a method chain" do
    it "stubs the called method name with the given value" do
      subject_class = Class.new
      existing_subject = subject_class.new
      new_instance_of(subject_class).foobar {:baz}

      subject_new = subject_class.new
      existing_subject.should_not respond_to(:foobar)
      subject_new.foobar.should == :baz

      subject_allocate = subject_class.allocate
      existing_subject.should_not respond_to(:foobar)
      subject_allocate.foobar.should == :baz
    end
  end

  context "when passed a block" do
    it "applies to instances instantiated before the Double expection was created" do
      subject_class = Class.new
      existing_subject = subject_class.new
      class_called = false
      new_instance_of(subject_class) do |o|
        stub(o).to_s {"Subject is stubbed"}
        stub.proxy(o).class {|klass| class_called = true; klass}
      end

      existing_subject.to_s.should_not == "Subject is stubbed"

      subject_new = subject_class.new
      subject_new.to_s.should == "Subject is stubbed"
      subject_new.class.should == subject_class
      class_called.should be_true

      subject_allocate = subject_class.allocate
      subject_allocate.to_s.should == "Subject is stubbed"
      subject_allocate.class.should == subject_class
    end
  end

  context "when passed a Hash" do
    it "stubs methods (key) with the value on instances instantiated before the Double expection was created" do
      subject_class = Class.new
      existing_subject = subject_class.new
      new_instance_of(subject_class, :to_s => "Subject is stubbed", :foobar => lambda {:baz})

      existing_subject.to_s.should_not == "Subject is stubbed"
      existing_subject.should_not respond_to(:foobar)

      subject_new = subject_class.new
      subject_new.to_s.should == "Subject is stubbed"
      subject_new.foobar.should == :baz
      
      subject_allocate = subject_class.allocate
      subject_allocate.to_s.should == "Subject is stubbed"
      subject_allocate.foobar.should == :baz
    end
  end
end
