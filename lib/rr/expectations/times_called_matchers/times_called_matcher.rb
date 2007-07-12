module RR
module Expectations
module TimesCalledMatchers
  class TimesCalledMatcher
    def initialize(times)
      @times = times
    end

    def matches?(times_called)
    end

    def attempt?(times_called)
    end

    def error_message(times_called)
      "Called #{times_called.inspect} #{pluralized_time(times_called)}. #{expected_message_part}"
    end

    protected
    def expected_message_part
      "Expected #{@times.inspect} times."
    end

    def pluralized_time(times_called)
      (times_called == 1) ? "time" : "times"
    end
  end
end
end
end