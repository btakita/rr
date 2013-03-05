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

      expect(subject.to_s).to eq "Subject is stubbed"
      expect(subject.class).to eq subject_class
      expect(class_called).to eq true
      expect(subject.foobar).to eq :baz

      RR.reset

      expect(subject.to_s).to_not eq "Subject is stubbed"
      class_called = false
      expect(subject.class).to eq subject_class
      expect(class_called).to eq false
      expect(subject).to_not respond_to(:baz)
    end
  end

  context "when passed a Hash" do
    it "stubs methods (key) with the value on instances instantiated before the Double expection was created" do
      subject_class = Class.new
      subject = subject_class.new
      expect(subject).to_not respond_to(:baz)

      any_instance_of(subject_class, :to_s => "Subject is stubbed", :foobar => lambda {:baz})

      expect(subject.to_s).to eq "Subject is stubbed"
      expect(subject.foobar).to eq :baz

      RR.reset

      expect(subject.to_s).to_not eq "Subject is stubbed"
      expect(subject).to_not respond_to(:baz)
    end
  end
end
