module RR
  class SpyVerification
    def initialize(subject, method_name, args)
      @subject = subject
      @method_name = method_name.to_sym
      set_argument_expectation_for_args(args)
      @ordered = false
      once
    end

    attr_reader :argument_expectation, :method_name, :times_matcher
    attr_accessor :subject

    include RR::Space::Reader
    include RR::DoubleDefinitions::DoubleDefinition::TimesDefinitionConstructionMethods
    include RR::DoubleDefinitions::DoubleDefinition::ArgumentDefinitionConstructionMethods
  
    def ordered
      @ordered = true
      self
    end
  
    def ordered?
      @ordered
    end

    def call
      verify_double_injection_exists
      if RR.recorded_calls.match_error(self)
        raise RR::Errors::SpyVerificationErrors::SpyVerificationError
      end
    end
  
  protected
    attr_writer :times_matcher

    def verify_double_injection_exists
      unless space.double_injection_exists?(subject, method_name)
        raise RR::Errors::SpyVerificationErrors::DoubleInjectionNotFoundError
      end
    end
  
    def set_argument_expectation_for_args(args)
      # with_no_args and with actually set @argument_expectation
      args.empty? ? with_no_args : with(*args)
    end
  
    def install_method_callback(return_value_block)
      # Do nothing. This is to support DefinitionConstructionMethods
    end
  end
end