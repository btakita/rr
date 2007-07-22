module RR
  # RR::ScenarioCreator is the superclass for all creators.
  class ScenarioCreator
    def initialize(space, subject, &block)
      @space = space
      @subject = subject
      class << self
        instance_methods.each do |m|
          undef_method m unless m =~ /^__/
        end

        def method_missing(method_name, *args, &block)
          self.create(method_name, *args, &block)
        end
        include self::InstanceMethods
      end
      yield(self) if block_given?
    end
  end
end
