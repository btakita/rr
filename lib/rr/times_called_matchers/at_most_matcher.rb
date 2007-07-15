module RR
module TimesCalledMatchers
  class AtMostMatcher < TimesCalledMatcher
    include Deterministic

    def possible_match?(times_called)
      times_called <= @times
    end

    def matches?(times_called)
      times_called <= @times
    end

    def attempt?(times_called)
      times_called < @times
    end

    protected
    def expected_message_part
      "Expected at most #{@times.inspect} times."
    end
  end
end
end