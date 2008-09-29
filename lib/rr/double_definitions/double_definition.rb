module RR
  module DoubleDefinitions
    class DoubleDefinition #:nodoc:
      ORIGINAL_METHOD = Object.new
      attr_accessor :argument_expectation,
                    :times_matcher,
                    :implementation,
                    :after_call_proc,
                    :yields_value,
                    :double
      attr_reader   :block_callback_strategy

      include Space::Reader

      def initialize(creator_proxy = nil)
        @implementation = nil
        @argument_expectation = nil
        @times_matcher = nil
        @after_call_proc = nil
        @yields_value = nil
        @creator_proxy = creator_proxy
        returns_block_callback_strategy
      end

      def with(*args, &return_value_block)
        @argument_expectation = Expectations::ArgumentEqualityExpectation.new(*args)
        install_method_callback return_value_block
        self
      end

      def with_any_args(&return_value_block)
        @argument_expectation = Expectations::AnyArgumentExpectation.new
        install_method_callback return_value_block
        self
      end

      def with_no_args(&return_value_block)
        @argument_expectation = Expectations::ArgumentEqualityExpectation.new()
        install_method_callback return_value_block
        self
      end

      def never
        @times_matcher = TimesCalledMatchers::IntegerMatcher.new(0)
        self
      end

      def once(&return_value_block)
        @times_matcher = TimesCalledMatchers::IntegerMatcher.new(1)
        install_method_callback return_value_block
        self
      end

      def twice(&return_value_block)
        @times_matcher = TimesCalledMatchers::IntegerMatcher.new(2)
        install_method_callback return_value_block
        self
      end

      def at_least(number, &return_value_block)
        @times_matcher = TimesCalledMatchers::AtLeastMatcher.new(number)
        install_method_callback return_value_block
        self
      end

      def at_most(number, &return_value_block)
        @times_matcher = TimesCalledMatchers::AtMostMatcher.new(number)
        install_method_callback return_value_block
        self
      end

      def any_number_of_times(&return_value_block)
        @times_matcher = TimesCalledMatchers::AnyTimesMatcher.new
        install_method_callback return_value_block
        self
      end

      def times(matcher_value, &return_value_block)
        @times_matcher = TimesCalledMatchers::TimesCalledMatcher.create(matcher_value)
        install_method_callback return_value_block
        self
      end

      def ordered(&return_value_block)
        raise(
          Errors::DoubleDefinitionError,
          "Double Definitions must have a dedicated Double to be ordered. " <<
          "For example, using instance_of does not allow ordered to be used. " <<
          "proxy the class's #new method instead."
        ) unless @double
        @ordered = true
        space.ordered_doubles << @double unless space.ordered_doubles.include?(@double)
        install_method_callback return_value_block
        @creator_proxy
      end
      alias_method :then, :ordered

      def ordered?
        @ordered
      end

      def yields(*args, &return_value_block)
        @yields_value = args
        install_method_callback return_value_block
        self
      end

      def after_call(&after_call_proc)
        raise ArgumentError, "after_call expects a block" unless after_call_proc
        @after_call_proc = after_call_proc
        self
      end

      def verbose(&after_call_proc)
        @verbose = true
        @after_call_proc = after_call_proc
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
          implemented_by lambda {value}
        end
        self
      end

      def mock(&definition_eval_block)
        returns object = Object.new
        DoubleDefinitionCreator.new.mock(object, &definition_eval_block)
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
        __send__(@block_callback_strategy, &block)
      end
    end    
  end
end