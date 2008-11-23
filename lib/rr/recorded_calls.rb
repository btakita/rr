module RR
  class RecordedCalls
    def initialize(recorded_calls=[])
      @recorded_calls = recorded_calls
      @ordered_index = 0
    end
  
    attr_reader :recorded_calls
  
    def clear
      self.ordered_index = 0
      recorded_calls.clear
    end
  
    def <<(recorded_call)
      recorded_calls << recorded_call
    end
  
    def any?(&block)
      recorded_calls.any?(&block)
    end
  
    def ==(other)
      recorded_calls == other.recorded_calls
    end
  
    def matches?(spy_verification)
      if spy_verification.ordered?
        ordered_matches?(spy_verification)
      else
        spy_verification.times_matcher.matches?(times_called(spy_verification))
      end
    end
  
    def ordered_matches?(spy_verification)
      matched_count = 0
      index = ordered_index
      while index < recorded_calls.size
        matched_count += 1 if matches_recorded_call?(recorded_calls[index],spy_verification)
        index = index + 1
        if spy_verification.times_matcher.matches?(matched_count)
          self.ordered_index = index
          return true
        end
      end
      false
    end
  
  protected
    attr_accessor :ordered_index

    def times_called(spy_verification)
      matching_calls = recorded_calls.select do |recorded_call|
        matches_recorded_call?(recorded_call, spy_verification)
      end
      matching_calls.size
    end

    def matches_recorded_call?(recorded_call, spy_verification)
#      puts "#{__FILE__}:#{__LINE__}"
#      p recorded_call[0] == spy_verification.subject
#      p recorded_call[1] == spy_verification.method_name
#      p spy_verification.argument_expectation
#      p spy_verification.argument_expectation.exact_match?(*recorded_call[2])
#      p spy_verification.argument_expectation.wildcard_match?(*recorded_call[2])
      recorded_call[0] == spy_verification.subject &&
      recorded_call[1] == spy_verification.method_name && 
      ( spy_verification.argument_expectation.exact_match?(*recorded_call[2]) ||
        spy_verification.argument_expectation.wildcard_match?(*recorded_call[2]))
    end
  end
end