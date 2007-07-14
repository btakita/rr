module RR
module TimesCalledMatchers
  class AnyTimesMatcher < TimesCalledMatcher
    def possible_match?(times_called)
      true
    end

    def matches?(times_called)
      true
    end

    def attempt?(times_called)
      true
    end

    protected
    def expected_message_part
      "Expected any number of times."
    end
  end
end
end