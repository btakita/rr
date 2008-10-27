module RR
  module DoubleDefinitions
    class DoubleDefinitionCreatorProxy
      def initialize(creator, &block) #:nodoc:
        @creator = creator
        class << self
          def __apply_blank_slate
            @apply_blank_slate = true
          end

          def __apply_blank_slate?
            @apply_blank_slate ||= false
          end

          instance_methods.each do |m|
            unless m =~ /^_/ || m.to_s == 'object_id' || m.to_s == "instance_eval" || m.to_s == 'respond_to?'
              alias_method "__blank_slated_#{m}", m
              undef_method m
            end
          end

          def instance_eval
            return_value = super
            class << self
              alias_method "__blank_slated_instance_eval", "instance_eval"
              undef_method :instance_eval
              alias_method "__blank_slated_respond_to?", "respond_to?"
              undef_method :respond_to?
            end
            return_value
          end

          def method_missing(method_name, *args, &block)
            if __apply_blank_slate?
              @creator.create(method_name, *args, &block)
            else
              __blank_slated_send("__blank_slated_#{method_name}", *args, &block)
            end
          end
        end

        __apply_blank_slate
        if block_given?
          if block.arity == 1
            yield(self)
          else
            instance_eval(&block)
          end
        end
      end

      def __creator__
        @creator
      end
    end    
  end
end