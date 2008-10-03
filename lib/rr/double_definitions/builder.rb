module RR
  module DoubleDefinitions
    class Builder #:nodoc:
      attr_reader :creator, :subject, :method_name, :args, :handler, :definition, :core_strategy
      include Errors
      include Space::Reader

      def initialize(creator)
        @creator = creator
        @using_proxy_strategy = false
        @using_instance_of_strategy = nil
        @core_strategy = nil
      end

      def build(subject, method_name, args, handler)
        @subject, @method_name, @args, @handler = subject, method_name, args, handler
        @definition = DoubleDefinition.new(creator, subject)
        create_double
        verify_strategy
        send(@core_strategy)
        using_proxy_strategy?? proxy : reimplementation
        @definition
      end

      def core_strategy=(strategy)
        verify_no_core_strategy
        @core_strategy = strategy
        proxy_when_dont_allow_error if strategy == :dont_allow && @using_proxy_strategy
        strategy
      end

      def use_proxy_strategy
        proxy_when_dont_allow_error if @core_strategy == :dont_allow
        @using_proxy_strategy = true
      end

      def using_proxy_strategy?
        !!@using_proxy_strategy
      end

      def use_instance_of_strategy
        @using_instance_of_strategy = true
      end

      def using_instance_of_strategy?
        !!@using_instance_of_strategy
      end

      protected
      def create_double
        if using_instance_of_strategy?
          create_doubles_for_instances_of_subject(method_name)
        else
          create_double_for_subject(method_name)
        end
      end

      def create_double_for_subject(method_name)
        double_injection = space.double_injection(subject, method_name)
        Double.new(double_injection, definition)
      end

      def create_doubles_for_instances_of_subject(instance_method_name)
        class_handler = lambda do |return_value|
          double_injection = space.double_injection(return_value, instance_method_name)
          Double.new(double_injection, definition)
          return_value
        end

        instance_of_subject_builder = Builder.new(creator)
        instance_of_subject_builder.core_strategy = :stub
        instance_of_subject_builder.use_proxy_strategy
        instance_of_subject_builder.build(subject, :new, [], class_handler)
      end

      def mock
        @definition.with(*@args).once
      end

      def stub
        @definition.any_number_of_times
        permissive_argument
      end

      def dont_allow
        @definition.never
        permissive_argument
        reimplementation
      end

      def permissive_argument
        if @args.empty?
          @definition.with_any_args
        else
          @definition.with(*@args)
        end
      end

      def reimplementation
        @definition.returns(&@handler)
      end

      def proxy
        @definition.after_call_block_callback_strategy
        @definition.proxy
        @definition.after_call(&@handler) if @handler
      end

      def verify_no_core_strategy
        strategy_already_defined_error if @core_strategy
      end

      def strategy_already_defined_error
        raise(
          DoubleDefinitionError,
          "This Double already has a #{@core_strategy} strategy"
        )
      end

      def proxy_when_dont_allow_error
        raise(
          DoubleDefinitionError,
          "Doubles cannot be proxied when using dont_allow strategy"
        )
      end

      def verify_strategy
        no_strategy_error unless @core_strategy
      end

      def no_strategy_error
        raise(
          DoubleDefinitionError,
          "This Double has no strategy"
        )
      end
    end
  end
end
