require "#{File.dirname(__FILE__)}/spec_helper"

describe "RR" do
  before do
    Object.class_eval do
      def verify
        raise "Dont call me"
      end
    end
  end

  after do
    Object.class_eval do
      remove_method :verify
    end
  end

  it "has proxy methods for each method defined directly on Space" do
    space_instance_methods = RR::Space.instance_methods(false)
    space_instance_methods.should_not be_empty

    rr_instance_methods = RR.methods(false)
    space_instance_methods.each do |space_instance_method|
      rr_instance_methods.should include(space_instance_method)
    end
    RR.verify
  end
end