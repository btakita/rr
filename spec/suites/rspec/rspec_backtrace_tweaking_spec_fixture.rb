
require File.expand_path('../spec_helper', __FILE__)

describe "Example" do
  it("hides RR framework in backtrace") do
    mock(subject).foobar()
    RR.verify_double(subject, :foobar)
  end
end
