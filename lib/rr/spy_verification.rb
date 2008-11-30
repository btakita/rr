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
      (error = RR.recorded_calls.match_error(self)) && raise(error)
    end

    def to_proc
      lambda do
        call
      end
    end
  
  protected
    attr_writer :times_matcher

    def set_argument_expectation_for_args(args)
      # with_no_args and with actually set @argument_expectation
      args.empty? ? with_no_args : with(*args)
    end
  
    def install_method_callback(return_value_block)
      # Do nothing. This is to support DefinitionConstructionMethods
    end
  end
end