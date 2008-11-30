require File.expand_path("#{File.dirname(__FILE__)}/spec_helper")

class Alpha
  def bob
  end
end

describe RR::SpyVerification do
  attr_reader :subject, :recorded_calls
  it_should_behave_like "Swapped Space"
  before(:each) do
    @subject = Object.new
    extend RR::Adapters::RRMethods
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
            lambda do
              received(subject).foobar(1, 2).call
            end.should raise_error(RR::Errors::SpyVerificationErrors::InvocationCountError)
          end
        end
      end

      context "when the number of times the subject received a method is specified" do
        context "as one time" do
          it "verifies that the method with arugments was called once" do
            subject.foobar(1, 2)
            received(subject).foobar(1, 2).once.call
            subject.foobar(1, 2)
            lambda do
              received(subject).foobar(1, 2).once.call
            end.should raise_error(RR::Errors::SpyVerificationErrors::InvocationCountError)
          end
        end

        context "as an at least matcher" do
          it "verifies that the method with arugments was called at least the specified number of times" do
            subject.foobar(1, 2)
            lambda do
              received(subject).foobar(1, 2).at_least(2).call
            end.should raise_error(RR::Errors::SpyVerificationErrors::InvocationCountError)
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
            lambda do
              received(subject).foobar(1, is_a(Fixnum)).call
            end.should raise_error(RR::Errors::SpyVerificationErrors::InvocationCountError)
          end
        end
      end

      context "when the number of times the subject received a method is specified" do
        context "as one time" do
          it "verifies that the method with arugments was called once" do
            subject.foobar(1, 2)
            received(subject).foobar(1, is_a(Fixnum)).once.call
            subject.foobar(1, 2)
            lambda do
              received(subject).foobar(1, is_a(Fixnum)).once.call
            end.should raise_error(RR::Errors::SpyVerificationErrors::InvocationCountError)
          end
        end

        context "as an at least matcher" do
          it "verifies that the method with arugments was called at least the specified number of times" do
            subject.foobar(1, is_a(Fixnum))
            lambda do
              received(subject).foobar(1, is_a(Fixnum)).at_least(2).call
            end.should raise_error(RR::Errors::SpyVerificationErrors::InvocationCountError)
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
        lambda do
          received(subject).foobar(1, 2).ordered.call
          received(subject).foobar(3, 4).ordered.call
        end.should raise_error(RR::Errors::SpyVerificationErrors::InvocationCountError)
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
        space.double_injection_exists?(subject, :method_that_does_not_exist).should be_false
        lambda do
          received(subject).method_that_does_not_exist.call
        end.should raise_error(RR::Errors::SpyVerificationErrors::DoubleInjectionNotFoundError)
      end
    end
  end
end