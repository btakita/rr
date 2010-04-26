require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe "new_instance_of" do
  context "when passed a block" do
    it "applies to instances instantiated before the Double expection was created" do
      subject_class = Class.new
      existing_subject = subject_class.new
      class_called = false
      new_instance_of(subject_class) do |o|
        stub(o).to_s {"Subject is stubbed"}
        stub.proxy(o).class {|klass| class_called = true; klass}
      end
      new_subject = subject_class.new

      existing_subject.to_s.should_not == "Subject is stubbed"

      new_subject.to_s.should == "Subject is stubbed"
      new_subject.class.should == subject_class
      class_called.should be_true
    end
  end

  context "when passed a Hash" do
    it "stubs methods (key) with the value on instances instantiated before the Double expection was created" do
      subject_class = Class.new
      existing_subject = subject_class.new
      new_instance_of(subject_class, :to_s => "Subject is stubbed", :foobar => lambda {:baz})
      new_subject = subject_class.new

      existing_subject.to_s.should_not == "Subject is stubbed"
      existing_subject.should_not respond_to(:foobar)

      new_subject.to_s.should == "Subject is stubbed"
      new_subject.foobar.should == :baz
    end
  end
end
