require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe RR do
  describe "#mock" do
    before do
      @subject = Object.new
    end

    it "creates a mock DoubleInjection Double" do
      mock(@subject).foobar(1, 2) {:baz}
      @subject.foobar(1, 2).should == :baz
    end
  end

  describe "#stub" do
    before do
      @subject = Object.new
    end

    it "creates a stub DoubleInjection Double" do
      stub(@subject).foobar {:baz}
      @subject.foobar("any", "thing").should == :baz
    end
  end

  describe "#mock and #proxy" do
    before do
      @subject = Object.new
      def @subject.foobar
        :baz
      end
    end

    it "creates a proxy DoubleInjection Double" do
      mock.proxy(@subject).foobar
      @subject.foobar.should == :baz
    end
  end

  describe "#stub and #proxy" do
    before do
      @subject = Object.new
      def @subject.foobar
        :baz
      end
    end

    it "creates a proxy DoubleInjection Double" do
      stub.proxy(@subject).foobar
      @subject.foobar.should == :baz
    end
  end

  describe "#stub and #proxy" do
    before do
      @subject = Object.new
      def @subject.foobar
        :baz
      end
    end

    it "creates a proxy DoubleInjection Double" do
      stub.proxy(@subject).foobar
      @subject.foobar.should == :baz
    end
  end
end
