require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe RR do
  subject { Object.new }

  # TODO: Not sure where this goes atm
  describe "spies" do
    it "validates that a Double was called after it was called" do
      stub(subject).foobar
      subject.foobar(1, 2)

      expect(subject).to have_received.foobar(1, 2)
      expect {
        expect(subject).to have_received.foobar(1, 2, 3)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end
end
