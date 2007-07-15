module RR
module TimesCalledMatchers
  module NonDeterministic
    def deterministic?
      false
    end

    def possible_match?(times_called)
      true
    end

    def attempt?(times_called)
      true
    end
  end
end
end