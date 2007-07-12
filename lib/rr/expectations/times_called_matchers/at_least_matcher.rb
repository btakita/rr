module RR
module Expectations
module TimesCalledMatchers
  class AtLeastMatcher < TimesCalledMatcher
    def possible_match?(times_called)
      true
    end

    def matches?(times_called)
      times_called >= @times
    end

    protected
    def expected_message_part
      "Expected at least #{@times.inspect} times."
    end
  end
end
end
end