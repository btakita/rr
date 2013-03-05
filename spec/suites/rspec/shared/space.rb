
shared_examples_for "Swapped Space" do
  attr_reader :space, :original_space

  before do
    @original_space = RR::Space.instance
    RR::Space.instance = RR::Space.new
    @space = RR::Space.instance
  end

  after do
    RR::Space.instance = @original_space
  end
end
