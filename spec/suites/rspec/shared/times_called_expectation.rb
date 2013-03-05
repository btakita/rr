shared_examples_for "RR::Expectations::TimesCalledExpectation" do
  include_examples "Swapped Space"

  subject { Object.new }

  def raises_expectation_error(&block)
    expect { block.call }.to raise_error(RR::Errors::TimesCalledError)
  end
end
