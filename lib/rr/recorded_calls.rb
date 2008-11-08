class RecordedCalls
  def initialize(recorded_calls=[])
    @recorded_calls = recorded_calls
  end
  
  attr_reader :recorded_calls
  
  def clear
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
    spy_verification.times_matcher.matches?(times_called(spy_verification))
  end
  
protected
  def times_called(spy_verification)
    recorded_calls.select do |recorded_call|
      matches_recorded_call?(recorded_call, spy_verification)
    end.size
  end

  def matches_recorded_call?(recorded_call, spy_verification)
    recorded_call[0] == spy_verification.subject &&
    recorded_call[1] == spy_verification.method_name && 
    ( spy_verification.argument_expectation.exact_match?(*recorded_call[2]) ||
      spy_verification.argument_expectation.wildcard_match?(*recorded_call[2]) )    
  end

end