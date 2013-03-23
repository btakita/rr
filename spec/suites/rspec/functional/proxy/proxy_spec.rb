require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe "proxy" do
  include RR::Adapters::RRMethods

  after(:each) do
    RR.reset
  end

  subject { Object.new }

  it "proxies via inline call" do
    expected_to_s_value = subject.to_s
    mock.proxy(subject).to_s
    expect(subject.to_s).to eq expected_to_s_value
    expect { subject.to_s }.to raise_error
  end

  it "proxy allows ordering" do
    def subject.to_s(arg)
      "Original to_s with arg #{arg}"
    end
    mock.proxy(subject).to_s(:foo).ordered
    mock.proxy(subject).to_s(:bar).twice.ordered

    expect(subject.to_s(:foo)).to eq "Original to_s with arg foo"
    expect(subject.to_s(:bar)).to eq "Original to_s with arg bar"
    expect(subject.to_s(:bar)).to eq "Original to_s with arg bar"
    expect { subject.to_s(:bar) }.to raise_error(RR::Errors::TimesCalledError)
  end

  it "proxy allows ordering" do
    def subject.to_s(arg)
      "Original to_s with arg #{arg}"
    end
    mock.proxy(subject).to_s(:foo).ordered
    mock.proxy(subject).to_s(:bar).twice.ordered

    expect(subject.to_s(:foo)).to eq "Original to_s with arg foo"
    expect(subject.to_s(:bar)).to eq "Original to_s with arg bar"
    expect(subject.to_s(:bar)).to eq "Original to_s with arg bar"
    expect { subject.to_s(:bar) }.to raise_error(RR::Errors::TimesCalledError)
  end

  it "proxies via block with argument" do
    def subject.foobar_1(*args)
      :original_value_1
    end

    def subject.foobar_2
      :original_value_2
    end

    mock.proxy subject do |c|
      c.foobar_1(1)
      c.foobar_2
    end
    expect(subject.foobar_1(1)).to eq :original_value_1
    expect { subject.foobar_1(:blah) }.to raise_error

    expect(subject.foobar_2).to eq :original_value_2
    expect { subject.foobar_2(:blah) }.to raise_error
  end

  it "proxies via block without argument" do
    def subject.foobar_1(*args)
      :original_value_1
    end

    def subject.foobar_2
      :original_value_2
    end

    mock.proxy subject do
      foobar_1(1)
      foobar_2
    end
    expect(subject.foobar_1(1)).to eq :original_value_1
    expect { subject.foobar_1(:blah) }.to raise_error

    expect(subject.foobar_2).to eq :original_value_2
    expect { subject.foobar_2(:blah) }.to raise_error
  end

  # bug #44
  describe 'when wrapped in an array that is then flattened' do
    context 'when the method being mocked is not defined' do
      it "does not raise an error" do
        mock.proxy(subject).foo
        expect([subject].flatten).to eq [subject]
      end

      it "honors a #to_ary that already exists" do
        subject.instance_eval do
          def to_ary; []; end
        end
        mock.proxy(subject).foo
        expect([subject].flatten).to eq []
      end
    end

    context 'when the method being mocked is defined' do
      before do
        subject.instance_eval do
          def foo; end
        end
      end

      it "does not raise an error" do
        mock.proxy(subject).foo
        expect([subject].flatten).to eq [subject]
      end

      it "honors a #to_ary that already exists" do
        eigen(subject).class_eval do
          def to_ary; []; end
        end
        mock.proxy(subject).foo
        expect([subject].flatten).to eq []
      end
    end
  end
end
