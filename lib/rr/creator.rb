module RR
  # RR::Creator is the superclass for all creators.
  class Creator
    def initialize(space, subject)
      @space = space
      @subject = subject
      class << self
        instance_methods.each do |m|
          undef_method m unless m =~ /^__/
        end
        include self::InstanceMethods
      end
      yield(self) if block_given?
    end
  end
end
