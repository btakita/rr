module RR
  class SpyVerification
    def initialize(subject)
      @subject = subject
      @ordered = false
      once
    end

    attr_reader :subject, :argument_expectation, :method_name, :times_matcher

    def method_missing(method_name, *args, &block)
      return super if !@method_name.nil?
      set_method_and_args(method_name, args)
      self
    end
  
    include RR::DoubleDefinitions::DoubleDefinition::TimesDefinitionConstructionMethods
    include RR::DoubleDefinitions::DoubleDefinition::ArgumentDefinitionConstructionMethods
  
    def ordered
      @ordered = true
      self
    end
  
    def ordered?
      @ordered
    end
  
  protected
    attr_writer :times_matcher
  
    def set_method_and_args(method_name, args)
      @method_name = method_name.to_sym
      with(*args) unless args.empty?
    end
  
    def install_method_callback(return_value_block)
      # Do nothing. This is to support DefinitionConstructionMethods
    end
  end
end