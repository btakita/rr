module RR
  module DoubleDefinitions
    class DoubleDefinitionCreatorProxy
      def initialize(creator, subject, &block) #:nodoc:
        @creator = creator
        @subject = subject
        class << self
          instance_methods.each do |m|
            unless m =~ /^_/ || m.to_s == 'object_id'
              undef_method m
            end
          end

          def method_missing(method_name, *args, &block)
            @creator.create(@subject, method_name, *args, &block)
          end
        end
        yield(self) if block_given?
      end
    end    
  end
end