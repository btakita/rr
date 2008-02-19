module RR
  class DoubleDefinition #:nodoc:
    ORIGINAL_METHOD = Object.new
    attr_accessor :times_called,
                  :argument_expectation,
                  :times_matcher,
                  :implementation,
                  :after_call_value,
                  :yields_value,
                  :double
    attr_reader   :block_callback_strategy

    def initialize(space)
      @space = space
      @implementation = nil
      @argument_expectation = nil
      @times_matcher = nil
      @after_call_value = nil
      @yields_value = nil
      returns_block_callback_strategy
    end

    def with(*args, &returns)
      @argument_expectation = Expectations::ArgumentEqualityExpectation.new(*args)
      install_method_callback returns
      self
    end

    def with_any_args(&returns)
      @argument_expectation = Expectations::AnyArgumentExpectation.new
      install_method_callback returns
      self
    end

    def with_no_args(&returns)
      @argument_expectation = Expectations::ArgumentEqualityExpectation.new()
      install_method_callback returns
      self
    end

    def never
      @times_matcher = TimesCalledMatchers::IntegerMatcher.new(0)
      self
    end

    def once(&returns)
      @times_matcher = TimesCalledMatchers::IntegerMatcher.new(1)
      install_method_callback returns
      self
    end

    def twice(&returns)
      @times_matcher = TimesCalledMatchers::IntegerMatcher.new(2)
      install_method_callback returns
      self
    end

    def at_least(number, &returns)
      @times_matcher = TimesCalledMatchers::AtLeastMatcher.new(number)
      install_method_callback returns
      self
    end

    def at_most(number, &returns)
      @times_matcher = TimesCalledMatchers::AtMostMatcher.new(number)
      install_method_callback returns
      self
    end

    def any_number_of_times(&returns)
      @times_matcher = TimesCalledMatchers::AnyTimesMatcher.new
      install_method_callback returns
      self
    end

    def times(matcher_value, &returns)
      @times_matcher = TimesCalledMatchers::TimesCalledMatcher.create(matcher_value)
      install_method_callback returns
      self
    end

    def ordered(&returns)
      raise(
        Errors::DoubleDefinitionError,
        "Double Definitions must have a dedicated Double to be ordered. " <<
        "For example, using instance_of does not allow ordered to be used. " <<
        "proxy the class's #new method instead."
      ) unless @double
      @ordered = true
      @space.ordered_doubles << @double unless @space.ordered_doubles.include?(@double)
      install_method_callback returns
      self
    end

    def ordered?
      @ordered
    end

    def yields(*args, &returns)
      @yields_value = args
      install_method_callback returns
      self
    end

    def after_call(&block)
      raise ArgumentError, "after_call expects a block" unless block
      @after_call_value = block
      self
    end

    def verbose(&block)
      @verbose = true
      @after_call_value = block
      self
    end

    def verbose?
      @verbose ? true : false
    end

    def returns(*args, &implementation)
      value = args.first
      if !args.empty? && implementation
        raise ArgumentError, "returns cannot accept both an argument and a block"
      end
      if implementation
        implemented_by implementation
      else
        implemented_by proc {value}
      end
      self
    end

    def proxy
      implemented_by ORIGINAL_METHOD
      self
    end

    def implemented_by(implementation)
      @implementation = implementation
      self
    end

    def exact_match?(*arguments)
      return false unless @argument_expectation
      @argument_expectation.exact_match?(*arguments)
    end

    def wildcard_match?(*arguments)
      return false unless @argument_expectation
      @argument_expectation.wildcard_match?(*arguments)
    end

    def terminal?
      return false unless @times_matcher
      @times_matcher.terminal?
    end

    def expected_arguments
      return [] unless argument_expectation
      argument_expectation.expected_arguments
    end

    def returns_block_callback_strategy # :nodoc:
      @block_callback_strategy = :returns
    end

    def after_call_block_callback_strategy # :nodoc:
      @block_callback_strategy = :after_call
    end

    protected
    def install_method_callback(block)
      return unless block
      case @block_callback_strategy
      when :returns; returns(&block)
      when :after_call; after_call(&block)
      else raise "Unknown block_callback_strategy: #{@block_callback_strategy.inspect}"
      end
    end
  end
end