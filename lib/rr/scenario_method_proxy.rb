module RR
  class ScenarioMethodProxy
    def initialize(space, creator, &block)
      @space = space
      @creator = creator
      class << self
        instance_methods.each do |m|
          undef_method m unless m =~ /^__/
        end

        def method_missing(method_name, *args, &block)
          @creator.create!(method_name, *args, &block)
        end
      end
      yield(self) if block_given?
    end
  end
end