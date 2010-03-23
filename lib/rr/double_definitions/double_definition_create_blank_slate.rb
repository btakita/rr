module RR
  module DoubleDefinitions
    class DoubleDefinitionCreateBlankSlate
      def initialize(double_definition_create, &block) #:nodoc:
        @double_definition_create = double_definition_create
        BlankSlate.call(respond_to?(:class) ? self.class : __blank_slated_class)

        if block_given?
          if block.arity == 1
            yield(self)
          else
            respond_to?(:instance_eval) ? instance_eval(&block) : __blank_slated_instance_eval(&block)
          end
        end
      end

      def method_missing(method_name, *args, &block)
        @double_definition_create.call(method_name, *args, &block)
      end

      def __double_definition_create__
        @double_definition_create
      end
    end    
  end
end