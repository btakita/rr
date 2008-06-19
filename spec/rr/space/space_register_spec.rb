require "spec/spec_helper"

module RR
  describe Space, "#register_ordered_double" do
    it_should_behave_like "RR::Space"

    before(:each) do
      @space = Space.new
      @original_space = Space.instance
      Space.instance = @space
      @object = Object.new
      @method_name = :foobar
      @double_injection = @space.double_injection(@object, @method_name)
    end

    after(:each) do
      Space.instance = @original_space
    end

    it "adds the ordered double to the ordered_doubles collection" do
      double1 = Double.new(@double_injection)

      @space.ordered_doubles.should == []
      @space.register_ordered_double double1
      @space.ordered_doubles.should == [double1]

      double2 = Double.new(@double_injection)
      @space.register_ordered_double double2
      @space.ordered_doubles.should == [double1, double2]
    end
  end
end
