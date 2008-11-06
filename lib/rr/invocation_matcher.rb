module RR
  class InvocationMatcher
    attr_reader :failure_message

    def initialize(method = nil)
      @method = method.to_sym if method
      at_least(1)
      with_any_args
    end

    def method_missing(method_name, *args, &block)
      @method = method_name.to_sym
      with(*args) unless args.empty?
      self
    end

    def with_any_args
      @args_expectation = Expectations::AnyArgumentExpectation.new
      self
    end

    def with(*args)
      @args_expectation = Expectations::ArgumentEqualityExpectation.new(*args)
      self
    end

    def with_no_args
      with()
    end

    def times(n)
      @times_matcher = TimesCalledMatchers::IntegerMatcher.new(n)
      self
    end

    def at_most(n)
      @times_matcher = TimesCalledMatchers::AtMostMatcher.new(n)
      self
    end

    def at_least(n)
      @times_matcher = TimesCalledMatchers::AtLeastMatcher.new(n)
      self
    end

    def never
      at_most(0)
    end

    def once
      times(1)
    end

    def twice
      times(2)
    end

    def any_number_of_times
      at_least(0)
    end

    def matches?(subject)
      @subject = subject
      check_doubles! && find_invocation! && check_invocation_count!
    end

    private

    def check_doubles!
      assert!(!double_injection.doubles.empty?,
              "No doubles...did you forget to set an expectation or stub?")
    end

    def find_invocation!
      @invocation = double_injection.invocation(@args_expectation)
      assert!(!@invocation.nil?, "Expected #{invocation_string} but never received it")
    end

    def check_invocation_count!
      assert!(@invocation.called?(@times_matcher),
              "#{invocation_string} #{times_error_message}")
    end

    def invocation_string
      Double::formatted_name(@method, @args_expectation.expected_arguments)
    end

    def times_error_message
      @times_matcher.error_message(@invocation.times_called)
    end

    def double_injection
      Space.instance.double_injection(@subject, @method)
    end

    def assert!(condition, message)
      if condition
        true
      else
        @failure_message = message
        false
      end
    end
  end
end
