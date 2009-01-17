module RR
  module DoubleDefinitions
    class DoubleDefinitionCreatorProxy
      class << self
        def blank_slate_methods
          instance_methods.each do |m|
            unless m =~ /^_/ || m.to_s == 'object_id' || m.to_s == 'respond_to?' || m.to_s == 'method_missing'
              alias_method "__blank_slated_#{m}", m
              undef_method m
            end
          end
        end
      end

      def initialize(creator, &block) #:nodoc:
        @creator = creator
        respond_to?(:class) ? self.class.blank_slate_methods : __blank_slated_class.blank_slate_methods

        if block_given?
          if block.arity == 1
            yield(self)
          else
            respond_to?(:instance_eval) ? instance_eval(&block) : __blank_slated_instance_eval(&block)
          end
        end
      end

      def method_missing(method_name, *args, &block)
        @creator.create(method_name, *args, &block)
      end

      def __creator__
        @creator
      end
    end    
  end
end