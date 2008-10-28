module RR
  module DoubleDefinitions
    class ChildDoubleDefinitionCreator < DoubleDefinitionCreator # :nodoc
      attr_reader :parent_double_definition
      def initialize(parent_double_definition)
        @parent_double_definition = parent_double_definition
        super()
      end

      def root_subject
        parent_double_definition.root_subject
      end

      def instance_of(*args)
        raise NoMethodError
      end

      protected
      def add_strategy(subject, method_name, definition_eval_block, &block)
        super do
          block.call
          parent_double_definition.implemented_by(lambda {subject})
        end
      end
    end
  end
end
