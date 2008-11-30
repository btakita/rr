module RR
  class RecordedCalls
    include RR::Space::Reader

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
      double_injection_exists_error(spy_verification) || begin
        if spy_verification.ordered?
          ordered_match_error(spy_verification)
        else
          unordered_match_error(spy_verification)
        end
      end
    end
  
  protected
    attr_accessor :ordered_index

    def double_injection_exists_error(spy_verification)
      unless space.double_injection_exists?(spy_verification.subject, spy_verification.method_name)
        RR::Errors::SpyVerificationErrors::DoubleInjectionNotFoundError.new(
          "A Double Injection for the subject and method call:\n" <<
          "#{spy_verification.subject.inspect}\n" <<
          "#{spy_verification.method_name}\ndoes not exist in:\n" <<
          "\t#{recorded_calls.map {|call| call.inspect}.join("\n\t")}"
        )
      end
    end    

    def ordered_match_error(spy_verification)
      memoized_matching_recorded_calls = matching_recorded_calls(spy_verification)

      if memoized_matching_recorded_calls.last
        self.ordered_index = recorded_calls.index(memoized_matching_recorded_calls.last)
      end
      (0..memoized_matching_recorded_calls.size).to_a.any? do |i|
        spy_verification.times_matcher.matches?(i)
      end ? nil : invocation_count_error(spy_verification, memoized_matching_recorded_calls)
    end

    def unordered_match_error(spy_verification)
      memoized_matching_recorded_calls = matching_recorded_calls(spy_verification)
      
      spy_verification.times_matcher.matches?(
        memoized_matching_recorded_calls.size
      ) ? nil : invocation_count_error(spy_verification, memoized_matching_recorded_calls)
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

    def invocation_count_error(spy_verification, matching_recorded_calls)
      RR::Errors::SpyVerificationErrors::InvocationCountError.new(
        "On subject #{spy_verification.subject.inspect}\n" <<
        "Expected #{Double.formatted_name(spy_verification.method_name, spy_verification.argument_expectation.expected_arguments)}\n" <<
        "to be called #{spy_verification.times_matcher.expected_times_message},\n" <<
        "but was called #{matching_recorded_calls.size} times.\n" <<
        "All of the method calls related to Doubles are:\n" <<
        "\t#{recorded_calls.map {|call| call.inspect}.join("\n\t")}"
      )
    end
  end
end