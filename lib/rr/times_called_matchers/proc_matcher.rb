module RR
module TimesCalledMatchers
  class ProcMatcher < TimesCalledMatcher
    def possible_match?(times_called)
      return true
    end

    def matches?(times_called)
      @times.call(times_called)
    end

    def attempt?(times_called)
      possible_match?(times_called)
    end
  end
end
end