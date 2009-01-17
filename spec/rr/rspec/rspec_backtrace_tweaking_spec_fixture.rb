require 'rubygems'
require "spec"
dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../../../lib/rr")

describe "Example" do
  it("hides RR framework in backtrace") do
    mock(subject).foobar()
    RR.verify_double(subject, :foobar)
  end
end
