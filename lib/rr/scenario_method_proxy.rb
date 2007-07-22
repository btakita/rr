module RR
  class ScenarioMethodProxy
    def initialize(space, creator, object, &block)
      @space = space
      @creator = creator
      @object = object
      class << self
        instance_methods.each do |m|
          undef_method m unless m =~ /^__/
        end

        def method_missing(method_name, *args, &block)
          @creator.create!(@object, method_name, *args, &block)
        end
      end
      yield(self) if block_given?
    end
  end
end