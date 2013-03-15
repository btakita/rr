# require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

shared_examples_for "RR::Adapters::RRMethods" do
  before do
    extend RR::Adapters::RRMethods
  end
end
