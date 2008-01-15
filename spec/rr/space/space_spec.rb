require "spec/spec_helper"

module RR
  describe Space, " class" do
    it_should_behave_like "RR::Space"

    before(:each) do
      @original_space = Space.instance
      @space = Space.new
      Space.instance = @space
    end

    after(:each) do
      Space.instance = @original_space
    end

    it "proxies to a singleton instance of Space" do
      create_double_args = nil
      (
      class << @space;
        self;
      end).class_eval do
        define_method :double_injection do |*args|
          create_double_args = args
        end
      end

      Space.double_injection(:foo, :bar)
      create_double_args.should == [:foo, :bar]
    end
  end
end
