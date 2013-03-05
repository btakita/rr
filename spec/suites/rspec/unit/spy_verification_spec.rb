require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

class Alpha
  def bob
  end
end

describe RR::SpyVerification do
  subject { Object.new }

  attr_reader :recorded_calls

  include_examples "Swapped Space"

  include RR::Adapters::RRMethods

  before(:each) do
    stub(subject).foobar
    @recorded_calls = RR::RecordedCalls.new([[subject, :foobar, [1, 2], nil]])
  end

  describe "#call" do
    context "when a subject is expected to receive a method with exact arguments" do
      context "when the number of times the subject received a method is not specified" do
        context "when there is an exact match one time" do
          it "verifies that the method with arguments was called once" do
            subject.foobar(1, 2)
            received(subject).foobar(1, 2).call
            subject.foobar(1, 2)
            expect {
              received(subject).foobar(1, 2).call
            }.to raise_error(RR::Errors::SpyVerificationErrors::InvocationCountError)
          end
        end
      end

      context "when the number of times the subject received a method is specified" do
        context "as one time" do
          it "verifies that the method with arugments was called once" do
            subject.foobar(1, 2)
            received(subject).foobar(1, 2).once.call
            subject.foobar(1, 2)
            expect {
              received(subject).foobar(1, 2).once.call
            }.to raise_error(RR::Errors::SpyVerificationErrors::InvocationCountError)
          end
        end

        context "as an at least matcher" do
          it "verifies that the method with arugments was called at least the specified number of times" do
            subject.foobar(1, 2)
            expect {
              received(subject).foobar(1, 2).at_least(2).call
            }.to raise_error(RR::Errors::SpyVerificationErrors::InvocationCountError)
            subject.foobar(1, 2)
            received(subject).foobar(1, 2).at_least(2).call
            subject.foobar(1, 2)
            received(subject).foobar(1, 2).at_least(2).call
          end
        end
      end
    end

    context "when a subject is expected to receive a method with wildcard arguments" do
      context "when the number of times the subject received a method is not specified" do
        context "when there is a wildcard match one time" do
          it "verifies that the method with arguments was called once" do
            subject.foobar(1, 2)
            received(subject).foobar(1, is_a(Fixnum)).call
            subject.foobar(1, 2)
            expect {
              received(subject).foobar(1, is_a(Fixnum)).call
            }.to raise_error(RR::Errors::SpyVerificationErrors::InvocationCountError)
          end
        end
      end

      context "when the number of times the subject received a method is specified" do
        context "as one time" do
          it "verifies that the method with arugments was called once" do
            subject.foobar(1, 2)
            received(subject).foobar(1, is_a(Fixnum)).once.call
            subject.foobar(1, 2)
            expect {
              received(subject).foobar(1, is_a(Fixnum)).once.call
            }.to raise_error(RR::Errors::SpyVerificationErrors::InvocationCountError)
          end
        end

        context "as an at least matcher" do
          it "verifies that the method with arugments was called at least the specified number of times" do
            subject.foobar(1, is_a(Fixnum))
            expect {
              received(subject).foobar(1, is_a(Fixnum)).at_least(2).call
            }.to raise_error(RR::Errors::SpyVerificationErrors::InvocationCountError)
            subject.foobar(1, 2)
            received(subject).foobar(1, is_a(Fixnum)).at_least(2).call
            subject.foobar(1, 2)
            received(subject).foobar(1, is_a(Fixnum)).at_least(2).call
          end
        end
      end
    end

    context "when checking for ordering" do
      it "when the order is incorrect; raises an error" do
        subject.foobar(3, 4)
        subject.foobar(1, 2)
        expect {
          received(subject).foobar(1, 2).ordered.call
          received(subject).foobar(3, 4).ordered.call
        }.to raise_error(RR::Errors::SpyVerificationErrors::InvocationCountError)
      end

      it "when the order is correct; does not raise an error" do
        subject.foobar(1, 2)
        subject.foobar(1, 2)
        subject.foobar(3, 4)
        received(subject).foobar(1, 2).ordered.call
        received(subject).foobar(3, 4).ordered.call
      end
    end

    context "when the subject is expected where there is not DoubleInjection" do
      it "raises a DoubleInjectionNotFoundError" do
        expect(::RR::Injections::DoubleInjection.exists?(subject, :method_that_does_not_exist)).to be_false
        expect {
          received(subject).method_that_does_not_exist.call
        }.to raise_error(RR::Errors::SpyVerificationErrors::DoubleInjectionNotFoundError)
      end
    end
  end
end
