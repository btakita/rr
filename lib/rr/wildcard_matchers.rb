=begin rdoc

= Writing your own custom wildcard matchers.
Writing new wildcard matchers is not too difficult.  If you've ever written
a custom expectation in RSpec, the implementation is very similar.

As an example, let's say that you want a matcher that will match any number
divisible by a certain integer.  In use, it might look like this:

  # Will pass if BananaGrabber#bunch_bananas is called with an integer
  # divisible by 5.

  mock(BananaGrabber).bunch_bananas(divisible_by(5))

To implement this, we need a class RR::WildcardMatchers::DivisibleBy with 
these instance methods:

* ==(other)
* eql?(other) (usually aliased to #==)
* inspect
* wildcard_match?(other)

and optionally, a sensible initialize method.  Let's look at each of these.

=== .initialize

Most custom wildcard matchers will want to define initialize to store
some information about just what should be matched.  DivisibleBy#initialize
might look like this:

  class RR::WildcardMatchers::DivisibleBy
    def initialize(divisor)
      @expected_divisor = divisor
    end
  end

=== #==(other)
DivisibleBy#==(other) should return true if other is a wildcard matcher that
matches the same things as self, so a natural way to write DivisibleBy#== is:

  
  class RR::WildcardMatchers::DivisibleBy
    def ==(other)
      # Ensure that other is actually a DivisibleBy
      return false unless other.is_a?(self.class)

      # Does other expect to match the same divisor we do?
      self.expected_divisor = other.expected_divisor
    end
  end

Note that this implementation of #== assumes that we've also declared
  attr_reader :expected_divisor

=== #inspect

Technically we don't have to declare DivisibleBy#inspect, since inspect is
defined for every object already.  But putting a helpful message in inspect
will make test failures much clearer, and it only takes about two seconds to
write it, so let's be nice and do so:

  class RR::WildcardMatchers::DivisibleBy
    def inspect
      "integer divisible by #{expected.divisor}"
    end
  end

Now if we run the example from above:

  mock(BananaGrabber).bunch_bananas(divisible_by(5))

and it fails, we get a helpful message saying

  bunch_bananas(integer divisible by 5)
  Called 0 times.
  Expected 1 times.

=== #wildcard_matches?(other)

wildcard_matches? is the method that actually checks the argument against the
expectation.  It should return true if other is considered to match,
false otherwise.  In the case of DivisibleBy, wildcard_matches? reads:

  class RR::WildcardMatchers::DivisibleBy
    def wildcard_matches?(other)
      # If other isn't a number, how can it be divisible by anything?
      return false unless other.is_a?(Numeric)

      # If other is in fact divisible by expected_divisor, then 
      # other modulo expected_divisor should be 0.

      other % expected_divisor == 0
    end
  end

=== A finishing touch: wrapping it neatly

We could stop here if we were willing to resign ourselves to using
DivisibleBy this way:

  mock(BananaGrabber).bunch_bananas(DivisibleBy.new(5))

But that's less expressive than the original:

  mock(BananaGrabber).bunch_bananas(divisible_by(5))

To be able to use the convenient divisible_by matcher rather than the uglier
DivisibleBy.new version, re-open the module RR::Adapters::RRMethods and
define divisible_by there as a simple wrapper around DivisibleBy.new:

  module RR::Adapters::RRMethods
    def divisible_by(expected_divisor)
      RR::WildcardMatchers::DivisibleBy.new(expected_divisor)
    end
  end

== Recap

Here's all the code for DivisibleBy in one place for easy reference:

  class RR::WildcardMatchers::DivisibleBy
    def initialize(divisor)
      @expected_divisor = divisor
    end

    def ==(other)
      # Ensure that other is actually a DivisibleBy
      return false unless other.is_a?(self.class)

      # Does other expect to match the same divisor we do?
      self.expected_divisor = other.expected_divisor
    end

    def inspect
      "integer divisible by #{expected.divisor}"
    end
  
    def wildcard_matches?(other)
      # If other isn't a number, how can it be divisible by anything?
      return false unless other.is_a?(Numeric)

      # If other is in fact divisible by expected_divisor, then 
      # other modulo expected_divisor should be 0.

      other % expected_divisor == 0
    end
  end
  
  module RR::Adapters::RRMethods
    def divisible_by(expected_divisor)
      RR::WildcardMatchers::DivisibleBy.new(expected_divisor)
    end
  end

=end

module RR::WildcardMatchers
end
