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
  
    def match_error(spy_verification)
      if spy_verification.ordered?
        ordered_match_error(spy_verification)
      else
        unordered_match_error(spy_verification)
      end
    end
  
  protected
    attr_accessor :ordered_index

#   def check_doubles!
#     assert!(!double_injection.doubles.empty?,
#             "No doubles...did you forget to set an expectation or stub?")
#   end
#
#   def find_invocation!
#     @invocation = double_injection.invocation(@args_expectation)
#     assert!(!@invocation.nil?, "Expected #{invocation_string} but never received it")
#   end
#
#   def check_invocation_count!
#     assert!(@invocation.called?(@times_matcher),
#             "#{invocation_string} #{times_error_message}")
#   end

    def ordered_match_error(spy_verification)
      memoized_matching_recorded_calls = matching_recorded_calls(spy_verification)

      if memoized_matching_recorded_calls.last
        self.ordered_index = recorded_calls.index(memoized_matching_recorded_calls.last)
      end
      (0..memoized_matching_recorded_calls.size).to_a.all? do |i|
        !spy_verification.times_matcher.matches?(i)
      end
    end

    def unordered_match_error(spy_verification)
      !spy_verification.times_matcher.matches?(
        matching_recorded_calls(spy_verification).size
      )
    end
    
    def matching_recorded_calls(spy_verification)
      recorded_calls[ordered_index..-1].
        select(&match_double_injection(spy_verification)).
        select(&match_argument_expectation(spy_verification))
    end

    def match_double_injection(spy_verification)
      lambda do |recorded_call|
        recorded_call[0] == spy_verification.subject &&
        recorded_call[1] == spy_verification.method_name
      end
    end

    def match_argument_expectation(spy_verification)
      lambda do |recorded_call|
        spy_verification.argument_expectation.exact_match?(*recorded_call[2]) ||
        spy_verification.argument_expectation.wildcard_match?(*recorded_call[2])
      end
    end
  end
end