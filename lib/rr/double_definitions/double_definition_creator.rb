module RR
  module DoubleDefinitions
    class DoubleDefinitionCreator # :nodoc
      attr_reader :builder
      NO_SUBJECT = Object.new

      include Space::Reader

      def initialize
        @core_strategy = nil
        @using_proxy_strategy = false
        @using_instance_of_strategy = nil
        @builder = Builders::Builder.new
      end

      def mock(subject=NO_SUBJECT, method_name=nil, &definition_eval_block) # :nodoc
        add_strategy(subject, method_name, definition_eval_block) do
          builder.set_core_strategy :mock
        end
      end

      def stub(subject=NO_SUBJECT, method_name=nil, &definition_eval_block) # :nodoc
        add_strategy(subject, method_name, definition_eval_block) do
          builder.set_core_strategy :stub
        end
      end

      def dont_allow(subject=NO_SUBJECT, method_name=nil, &definition_eval_block) # :nodoc
        add_strategy(subject, method_name, definition_eval_block) do
          builder.set_core_strategy :dont_allow
        end
      end
      alias_method :do_not_allow, :dont_allow
      alias_method :dont_call, :dont_allow
      alias_method :do_not_call, :dont_allow

      def proxy(subject=NO_SUBJECT, method_name=nil, &definition_eval_block) # :nodoc
        add_strategy(subject, method_name, definition_eval_block) do
          builder.using_proxy_strategy
        end
      end
      alias_method :probe, :proxy

      def instance_of(subject=NO_SUBJECT, method_name=nil, &definition_eval_block) # :nodoc
        if subject != NO_SUBJECT && !subject.is_a?(Class)
          raise ArgumentError, "instance_of only accepts class objects" unless subject.is_a?(Class)
        end
        add_strategy(subject, method_name, definition_eval_block) do
          @using_instance_of_strategy = true
          return self if subject === NO_SUBJECT
        end
      end

      def create(subject, method_name, *args, &handler)
        @args = args
        @handler = handler
        if @using_instance_of_strategy
          setup_doubles_for_class_instances(subject, method_name)
        else
          setup_double(subject, method_name)
        end
        builder.build(@definition, @args, @handler)
        @definition
      end

      protected
      def add_strategy(subject, method_name, definition_eval_block)
        if method_name && definition_eval_block
          raise ArgumentError, "Cannot pass in a method name and a block"
        end
        yield
        if no_subject?(subject)
          self
        elsif method_name
          create subject, method_name, &definition_eval_block
        else
          DoubleDefinitionCreatorProxy.new(self, subject, &definition_eval_block)
        end
      end

      def no_subject?(subject)
        subject.__id__ === NO_SUBJECT.__id__
      end

      def setup_double(subject, method_name)
        @double_injection = space.double_injection(subject, method_name)
        @double = Double.new(@double_injection, DoubleDefinition.new(self, subject))
        @definition = @double.definition
      end

      def setup_doubles_for_class_instances(subject, method_name)
        class_double = space.double_injection(subject, :new)
        class_double = Double.new(class_double, DoubleDefinition.new(self, subject))

        instance_method_name = method_name

        @definition = DoubleDefinition.new(self, subject)
        class_handler = lambda do |return_value|
          double_injection = space.double_injection(return_value, instance_method_name)
          Double.new(double_injection, @definition)
          return_value
        end

        builder = Builders::Builder.new
        builder.set_core_strategy(:stub)
        builder.using_proxy_strategy
        builder.build(class_double.definition, [], class_handler)
      end
    end
  end
end
