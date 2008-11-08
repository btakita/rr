class SpyVerification
  
  def initialize(subject)
    @subject = subject
    once
  end

  attr_reader :subject, :argument_expectation, :method_name, :times_matcher

  def method_missing(method_name, *args, &block)
    return super if !@method_name.nil?
    
    @method_name = method_name.to_sym
    with(*args) unless args.empty?
    self
  end
  
  include RR::DoubleDefinitions::DoubleDefinition::TimesDefinitionConstructionMethods
  include RR::DoubleDefinitions::DoubleDefinition::ArgumentDefinitionConstructionMethods
  
protected
  attr_writer :times_matcher
  
  def install_method_callback(return_value_block)
    # Do nothing. This is to support DefinitionConstructionMethods
  end
end