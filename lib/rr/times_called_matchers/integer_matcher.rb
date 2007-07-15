module RR
module TimesCalledMatchers
  class IntegerMatcher < TimesCalledMatcher
    include Deterministic
    
    def possible_match?(times_called)
      times_called <= @times
    end

    def matches?(times_called)
      times_called == @times
    end

    def attempt?(times_called)
      times_called < @times
    end
  end
end
end