require "examples/example_helper"

describe RR, "#mock" do
  before do
    @subject = Object.new
  end

  it "creates a mock Double Scenario" do
    mock(@subject).foobar(1, 2) {:baz}
    @subject.foobar(1, 2).should == :baz
  end
end

describe RR, "#stub" do
  before do
    @subject = Object.new
  end

  it "creates a stub Double Scenario" do
    stub(@subject).foobar {:baz}
    @subject.foobar("any", "thing").should == :baz
  end
end

describe RR, "#mock and #probe" do
  before do
    @subject = Object.new
    def @subject.foobar
      :baz
    end
  end

  it "creates a probe Double Scenario" do
    mock.probe(@subject).foobar
    @subject.foobar.should == :baz
  end
end

describe RR, "#stub and #probe" do
  before do
    @subject = Object.new
    def @subject.foobar
      :baz
    end
  end

  it "creates a probe Double Scenario" do
    stub.probe(@subject).foobar
    @subject.foobar.should == :baz
  end
end
