require "rubygems"
require "spec/mocks"
require "benchmark"

o = Object.new

Benchmark.bm do |x|
  x.report do
    1000.times do
      o.should_receive(:foobar).and_return("baz")
      o.foobar
    end
  end
end
