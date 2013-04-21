require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")


describe RR::Injections::MethodMissingInjection do

  context "#bind_method" do
    it 'should not change the behavior of respond_to?' do
      o = Object.new
      stub(o).some_method { true }
      o.respond_to?(:another_method).should be_false
      lambda { o.another_method }.should raise_error(NoMethodError)
      o.respond_to?(:another_method).should be_false
    end

  end

end
