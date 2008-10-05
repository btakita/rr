module RR
  module DoubleDefinitions
    class DoubleDefinitionCreator # :nodoc
      attr_reader :builder
      NO_SUBJECT = Object.new

      include Space::Reader

      def initialize
        @builder = Builder.new(self)
      end

      def mock(subject=NO_SUBJECT, method_name=nil, &definition_eval_block) # :nodoc
        add_strategy(subject, method_name, definition_eval_block) do
          builder.verification_strategy = Strategies::Verification::Mock.new
        end
      end

      def stub(subject=NO_SUBJECT, method_name=nil, &definition_eval_block) # :nodoc
        add_strategy(subject, method_name, definition_eval_block) do
          builder.verification_strategy = Strategies::Verification::Stub.new
        end
      end

      def dont_allow(subject=NO_SUBJECT, method_name=nil, &definition_eval_block) # :nodoc
        add_strategy(subject, method_name, definition_eval_block) do
          builder.verification_strategy = Strategies::Verification::DontAllow.new
        end
      end
      alias_method :do_not_allow, :dont_allow
      alias_method :dont_call, :dont_allow
      alias_method :do_not_call, :dont_allow

      def proxy(subject=NO_SUBJECT, method_name=nil, &definition_eval_block) # :nodoc
        add_strategy(subject, method_name, definition_eval_block) do
          builder.implementation_strategy = Strategies::Implementation::Proxy.new
        end
      end
      alias_method :probe, :proxy

      def instance_of(subject=NO_SUBJECT, method_name=nil, &definition_eval_block) # :nodoc
        if !no_subject?(subject) && !subject.is_a?(Class)
          raise ArgumentError, "instance_of only accepts class objects" unless subject.is_a?(Class)
        end
        add_strategy(subject, method_name, definition_eval_block) do
          builder.scope_strategy = Strategies::Scope::InstanceOfClass.new
        end
      end

      def create(subject, method_name, *args, &handler)
        builder.build(subject, method_name, args, handler)
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
          create(subject, method_name, &definition_eval_block)
        else
          DoubleDefinitionCreatorProxy.new(self, subject, &definition_eval_block)
        end
      end

      def no_subject?(subject)
        subject.__id__ === NO_SUBJECT.__id__
      end
    end
  end
end
