module RR
  module Adapters
    module RRMethods
      include ::RR::DoubleDefinitions::Strategies::StrategyMethods
      def mock(subject=DoubleDefinitions::DoubleDefinitionCreate::NO_SUBJECT, method_name=nil, &definition_eval_block)
        double_definition_create = DoubleDefinitions::DoubleDefinitionCreate.new
        double_definition_create.mock(subject, method_name, &definition_eval_block)
      end

      def stub(subject=DoubleDefinitions::DoubleDefinitionCreate::NO_SUBJECT, method_name=nil, &definition_eval_block)
        double_definition_create = DoubleDefinitions::DoubleDefinitionCreate.new
        double_definition_create.stub(subject, method_name, &definition_eval_block)
      end

      def dont_allow(subject=DoubleDefinitions::DoubleDefinitionCreate::NO_SUBJECT, method_name=nil, &definition_eval_block)
        double_definition_create = DoubleDefinitions::DoubleDefinitionCreate.new
        double_definition_create.dont_allow(subject, method_name, &definition_eval_block)
      end

      def proxy(subject=DoubleDefinitions::DoubleDefinitionCreate::NO_SUBJECT, method_name=nil, &definition_eval_block)
        double_definition_create = DoubleDefinitions::DoubleDefinitionCreate.new
        double_definition_create.proxy(subject, method_name, &definition_eval_block)
      end

      def strong(subject=DoubleDefinitions::DoubleDefinitionCreate::NO_SUBJECT, method_name=nil, &definition_eval_block)
        double_definition_create = DoubleDefinitions::DoubleDefinitionCreate.new
        double_definition_create.strong(subject, method_name, &definition_eval_block)
      end

      def instance_of(subject=DoubleDefinitions::DoubleDefinitionCreate::NO_SUBJECT, method_name=nil, &definition_eval_block)
        double_definition_create = DoubleDefinitions::DoubleDefinitionCreate.new
        double_definition_create.instance_of(subject, method_name, &definition_eval_block)
      end
      alias_method :any_instance_of, :instance_of
      alias_method :all_instances_of, :instance_of

      # Verifies all the DoubleInjection objects have met their
      # TimesCalledExpectations.
      def verify
        RR::Space.instance.verify_doubles
      end

      # Resets the registered Doubles and ordered Doubles
      def reset
        RR::Space.instance.reset
      end

      # Returns a AnyTimesMatcher. This is meant to be passed in as an argument
      # to Double#times.
      #
      #   mock(object).method_name(anything).times(any_times) {return_value}
      def any_times
        TimesCalledMatchers::AnyTimesMatcher.new
      end

      # Sets up an Anything wildcard ArgumentEqualityExpectation
      # that succeeds when passed any argument.
      #   mock(object).method_name(anything) {return_value}
      #   object.method_name("an arbitrary value") # passes
      def anything
        RR::WildcardMatchers::Anything.new
      end

      # Sets up an IsA wildcard ArgumentEqualityExpectation
      # that succeeds when passed an argument of a certain type.
      #   mock(object).method_name(is_a(String)) {return_value}
      #   object.method_name("A String") # passes
      def is_a(klass)
        RR::WildcardMatchers::IsA.new(klass)
      end

      # Sets up an Numeric wildcard ArgumentEqualityExpectation
      # that succeeds when passed an argument that is ::Numeric.
      #   mock(object).method_name(numeric) {return_value}
      #   object.method_name(99) # passes
      def numeric
        RR::WildcardMatchers::Numeric.new
      end

      # Sets up an Boolean wildcard ArgumentEqualityExpectation
      # that succeeds when passed an argument that is a ::Boolean.
      #   mock(object).method_name(boolean) {return_value}
      #   object.method_name(false) # passes
      def boolean
        RR::WildcardMatchers::Boolean.new
      end

      # Sets up a DuckType wildcard ArgumentEqualityExpectation
      # that succeeds when the passed argument implements the methods.
      #   arg = Object.new
      #   def arg.foo; end
      #   def arg.bar; end
      #   mock(object).method_name(duck_type(:foo, :bar)) {return_value}
      #   object.method_name(arg) # passes
      def duck_type(*args)
        RR::WildcardMatchers::DuckType.new(*args)
      end

      # Sets up a HashIncluding wildcard ArgumentEqualityExpectation
      # that succeeds when the passed argument contains at least those keys
      # and values of the expectation.
      #   mock(object).method_name(hash_including(:foo => 1)) {return_value}
      #   object.method_name({:foo => 1, :bar => 2) # passes
      def hash_including(expected_hash)
        RR::WildcardMatchers::HashIncluding.new(expected_hash)
      end

      # Sets up a Satisfy wildcard ArgumentEqualityExpectation
      # that succeeds when the passed argument causes the expectation's
      # proc to return true.
      #   mock(object).method_name(satisfy {|arg| arg == :foo}) {return_value}
      #   object.method_name(:foo) # passes
      def satisfy(expectation_proc=nil, &block)
        expectation_proc ||= block
        RR::WildcardMatchers::Satisfy.new(expectation_proc)
      end

      def spy(subject)
        methods_to_stub = subject.public_methods.map {|method_name| method_name.to_sym} -
          [:methods, :==, :__send__, :__id__, :object_id, :class]
        methods_to_stub.each do |method|
          stub.proxy(subject, method)
        end
      end

      def received(subject)
        RR::SpyVerificationProxy.new(subject)
      end

      def new_instance_of(*args, &block)
        RR::DoubleDefinitions::DoubleInjections::NewInstanceOf.call(*args, &block)
      end

      def any_instance_of(*args, &block)
        RR::DoubleDefinitions::DoubleInjections::AnyInstanceOf.call(*args, &block)
      end

      instance_methods.each do |name|
        alias_method "rr_#{name}", name
      end
    end
  end
  module Extensions
    InstanceMethods = Adapters::RRMethods
  end
end
