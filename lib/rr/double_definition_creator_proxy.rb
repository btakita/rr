module RR
  class DoubleDefinitionCreatorProxy
    def initialize(creator, object, &block) #:nodoc:
      @creator = creator
      @object = object
      class << self
        instance_methods.each do |m|
          unless m =~ /^_/ || m.to_s == 'object_id'
            undef_method m
          end
        end

        def method_missing(method_name, *args, &block)
          @creator.create(@object, method_name, *args, &block)
        end
      end
      yield(self) if block_given?
    end
  end
end