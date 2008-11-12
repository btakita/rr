module RR
  module DoubleDefinitions
    class DoubleDefinition #:nodoc:
      class << self
        def register_strategy_class(strategy_class, method_name)
          class_eval((<<-CLASS), __FILE__, __LINE__ + 1)
          def #{method_name}(subject=DoubleDefinitionCreator::NO_SUBJECT, method_name=nil, &definition_eval_block)
            ChildDoubleDefinitionCreator.new(self).#{method_name}(subject, method_name, &definition_eval_block)
          end
          CLASS

          class_eval((<<-CLASS), __FILE__, __LINE__ + 1)
          def #{method_name}!(method_name=nil, &definition_eval_block)
            ChildDoubleDefinitionCreator.new(self).#{method_name}!(method_name, &definition_eval_block)
          end
          CLASS
        end
      end

      ORIGINAL_METHOD = Object.new
      attr_accessor(
        :argument_expectation,
        :times_matcher,
        :implementation,
        :after_call_proc,
        :yields_value,
        :double,
        :double_definition_creator,
        :subject
      )

      include Space::Reader

      def initialize(double_definition_creator, subject)
        @implementation = nil
        @argument_expectation = nil
        @times_matcher = nil
        @after_call_proc = nil
        @yields_value = nil
        @double_definition_creator = double_definition_creator
        @subject = subject
      end
      
      attr_reader :argument_expectation

      def root_subject
        double_definition_creator.root_subject
      end
      
      module ArgumentDefinitionConstructionMethods
        # Double#with sets the expectation that the Double will receive
        # the passed in arguments.
        #
        # Passing in a block sets the return value.
        #
        #   mock(subject).method_name.with(1, 2) {:return_value}        
        def with(*args, &return_value_block)
          @argument_expectation = Expectations::ArgumentEqualityExpectation.new(*args)
          install_method_callback return_value_block
          self
        end

        # Double#with_any_args sets the expectation that the Double can receive
        # any arguments.
        #
        # Passing in a block sets the return value.
        #
        #   mock(subject).method_name.with_any_args {:return_value}
        def with_any_args(&return_value_block)
          @argument_expectation = Expectations::AnyArgumentExpectation.new
          install_method_callback return_value_block
          self
        end

        # Double#with_no_args sets the expectation that the Double will receive
        # no arguments.
        #
        # Passing in a block sets the return value.
        #
        #   mock(subject).method_name.with_no_args {:return_value}
        def with_no_args(&return_value_block)
          @argument_expectation = Expectations::ArgumentEqualityExpectation.new()
          install_method_callback return_value_block
          self
        end        
      end
      include ArgumentDefinitionConstructionMethods

      module TimesDefinitionConstructionMethods
        # Double#never sets the expectation that the Double will never be
        # called.
        #
        # This method does not accept a block because it will never be called.
        #
        #   mock(subject).method_name.never
        def never
          @times_matcher = TimesCalledMatchers::IntegerMatcher.new(0)
          self
        end

        # Double#once sets the expectation that the Double will be called
        # 1 time.
        #
        # Passing in a block sets the return value.
        #
        #   mock(subject).method_name.once {:return_value}
        def once(&return_value_block)
          @times_matcher = TimesCalledMatchers::IntegerMatcher.new(1)
          install_method_callback return_value_block
          self
        end

        # Double#twice sets the expectation that the Double will be called
        # 2 times.
        #
        # Passing in a block sets the return value.
        #
        #   mock(subject).method_name.twice {:return_value}        
        def twice(&return_value_block)
          @times_matcher = TimesCalledMatchers::IntegerMatcher.new(2)
          install_method_callback return_value_block
          self
        end

        # Double#at_least sets the expectation that the Double
        # will be called at least n times.
        # It works by creating a TimesCalledExpectation.
        #
        # Passing in a block sets the return value.
        #
        #   mock(subject).method_name.at_least(4) {:return_value}
        def at_least(number, &return_value_block)
          @times_matcher = TimesCalledMatchers::AtLeastMatcher.new(number)
          install_method_callback return_value_block
          self
        end

        # Double#at_most allows sets the expectation that the Double
        # will be called at most n times.
        # It works by creating a TimesCalledExpectation.
        #
        # Passing in a block sets the return value.
        #
        #   mock(subject).method_name.at_most(4) {:return_value}        
        def at_most(number, &return_value_block)
          @times_matcher = TimesCalledMatchers::AtMostMatcher.new(number)
          install_method_callback return_value_block
          self
        end

        # Double#any_number_of_times sets an that the Double will be called
        # any number of times. This effectively removes the times called expectation
        # from the Doublen
        #
        # Passing in a block sets the return value.
        #
        #   mock(subject).method_name.any_number_of_times        
        def any_number_of_times(&return_value_block)
          @times_matcher = TimesCalledMatchers::AnyTimesMatcher.new
          install_method_callback return_value_block
          self
        end

        # Double#times creates an TimesCalledExpectation of the passed
        # in number.
        #
        # Passing in a block sets the return value.
        #
        #   mock(subject).method_name.times(4) {:return_value}        
        def times(matcher_value, &return_value_block)
          @times_matcher = TimesCalledMatchers::TimesCalledMatcher.create(matcher_value)
          install_method_callback return_value_block
          self
        end
      end
      include TimesDefinitionConstructionMethods

      module DefinitionConstructionMethods
        # Double#ordered sets the Double to have an ordered
        # expectation.
        #
        # Passing in a block sets the return value.
        #
        #   mock(subject).method_name.ordered {return_value}
        def ordered(&return_value_block)
          raise(
            Errors::DoubleDefinitionError,
            "Double Definitions must have a dedicated Double to be ordered. " <<
            "For example, using instance_of does not allow ordered to be used. " <<
            "proxy the class's #new method instead."
          ) unless @double
          @ordered = true
          space.register_ordered_double(@double)
          install_method_callback return_value_block
          DoubleDefinitionCreatorProxy.new(double_definition_creator)
        end
        alias_method :then, :ordered

        # Double#yields sets the Double to invoke a passed in block when
        # the Double is called.
        # An Expection will be raised if no block is passed in when the
        # Double is called.
        #
        # Passing in a block sets the return value.
        #
        #   mock(subject).method_name.yields(yield_arg1, yield_arg2) {return_value}
        #   subject.method_name {|yield_arg1, yield_arg2|}
        def yields(*args, &return_value_block)
          @yields_value = args
          install_method_callback return_value_block
          self
        end

        # Double#after_call creates a callback that occurs after call
        # is called. The passed in block receives the return value of
        # the Double being called.
        # An Expection will be raised if no block is passed in.
        #
        #   mock(subject).method_name {return_value}.after_call {|return_value|}
        #   subject.method_name # return_value
        #
        # This feature is built into proxies.
        #   mock.proxy(User).find('1') {|user| mock(user).valid? {false}}
        def after_call(&after_call_proc)
          raise ArgumentError, "after_call expects a block" unless after_call_proc
          @after_call_proc = after_call_proc
          self
        end

        # Double#verbose sets the Double to print out each method call it receives.
        #
        # Passing in a block sets the return value
        def verbose(&after_call_proc)
          @verbose = true
          @after_call_proc = after_call_proc
          self
        end

        # Double#returns accepts an argument value or a block.
        # It will raise an ArgumentError if both are passed in.
        #
        # Passing in a block causes Double to return the return value of
        # the passed in block.
        #
        # Passing in an argument causes Double to return the argument.
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

        def implemented_by_original_method
          implemented_by ORIGINAL_METHOD
          self
        end

        # Double#implemented_by sets the implementation of the Double.
        # This method takes a Proc or a Method. Passing in a Method allows
        # the Double to accept blocks.
        #
        #   obj = Object.new
        #   def obj.foobar
        #     yield(1)
        #   end
        #   mock(obj).method_name.implemented_by(obj.method(:foobar))
        def implemented_by(implementation)
          @implementation = implementation
          self
        end

        def verify_method_signature
          @verify_method_signature = true
          self
        end
        alias_method :strong, :verify_method_signature
        
        protected
        def install_method_callback(block)
          return unless block
          if implementation_is_original_method?
            after_call(&block)
          else
            returns(&block)
          end
        end
      end
      include DefinitionConstructionMethods

      module StateQueryMethods
        # Double#ordered? returns true when the Double is ordered.
        #
        #   mock(subject).method_name.ordered?
        def ordered?
          @ordered
        end

        # Double#verbose? returns true when verbose has been called on it. It returns
        # true when the double is set to print each method call it receives.
        def verbose?
          @verbose ? true : false
        end

        def exact_match?(*arguments)
          raise(Errors::DoubleDefinitionError, "#argument_expectation must be defined on #{inspect}") unless @argument_expectation
          @argument_expectation.exact_match?(*arguments)
        end

        def wildcard_match?(*arguments)
          raise(Errors::DoubleDefinitionError, "#argument_expectation must be defined on #{inspect}") unless @argument_expectation
          @argument_expectation.wildcard_match?(*arguments)
        end

        def terminal?
          raise(Errors::DoubleDefinitionError, "#argument_expectation must be defined on #{inspect}") unless @times_matcher
          @times_matcher.terminal?
        end

        def expected_arguments
          argument_expectation ? argument_expectation.expected_arguments : []
        end

        def implementation_is_original_method?
          implementation_strategy.is_a?(Strategies::Implementation::Proxy)
        end

        def verify_method_signature?
          !!@verify_method_signature
        end
        alias_method :strong?, :verify_method_signature?        

        protected
        def implementation_strategy
          double_definition_creator.implementation_strategy
        end
      end
      include StateQueryMethods
    end
  end
end