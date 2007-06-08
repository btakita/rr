dir = File.dirname(__FILE__)
require "#{dir}/../../example_helper"

describe Kernel, "#expect" do
  it "sets up the RR call chain" do
    Object.new.instance_eval do
      proxy = expect
      class << proxy
        attr_reader :subject
      end
      proxy.subject.class.should == Object
    end
  end
end
