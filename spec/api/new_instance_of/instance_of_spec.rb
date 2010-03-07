require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe "instance_of" do
  it "applies to instances instantiated before the Double expection was created" do
    subject_class = Class.new
    existing_subject = subject_class.new
    stub.instance_of(subject_class) do |o|
      o.to_s {"Subject is stubbed"}
    end
    new_subject = subject_class.new

    existing_subject.to_s.should_not == "Subject is stubbed"
    new_subject.to_s.should == "Subject is stubbed"
  end
end
