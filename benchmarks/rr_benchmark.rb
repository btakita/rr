dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../lib/rr")
require "benchmark"

o = Object.new

Benchmark.bm do |x|
  x.report do
    1000.times do
      RR.mock(o).foobar.returns("baz")
      o.foobar
      RR.reset
    end
  end
end

#require "ruby-prof"
#RubyProf.start
#
##RR.mock(o).foobar.returns("baz")
##o.foobar
#10.times do
#  RR.mock(o).foobar.returns("baz")
#  o.foobar
#  RR.reset
#end
#
#result = RubyProf.stop
#
## Print a flat profile to text
#printer = RubyProf::FlatPrinter.new(result)
#printer.print(STDOUT, 0)