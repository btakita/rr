require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe RR::Adapters::RRMethods, "#any_times" do
  it_should_behave_like "RR::Adapters::RRMethods"

  it "returns an AnyTimesMatcher" do
    expect(any_times).to eq RR::TimesCalledMatchers::AnyTimesMatcher.new
  end

  it "rr_any_times returns an AnyTimesMatcher" do
    expect(rr_any_times).to eq RR::TimesCalledMatchers::AnyTimesMatcher.new
  end
end
