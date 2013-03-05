shared_examples_for "RR::Expectations::TimesCalledExpectation" do
  attr_reader :subject
  it_should_behave_like "Swapped Space"
  before do
    @subject = Object.new
  end

  def raises_expectation_error(&block)
    expect { block.call }.to raise_error(RR::Errors::TimesCalledError)
  end
end
