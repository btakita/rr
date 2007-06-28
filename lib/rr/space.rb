module RR
  class Space
    class << self
      def instance
        @instance ||= new
      end
      attr_writer :instance
      
      protected
      def method_missing(method_name, *args, &block)
        instance.__send__(method_name, *args, &block)
      end
    end

    attr_reader :doubles, :ordered_scenarios
    def initialize
      @doubles = Hash.new {|hash, subject_object| hash[subject_object] = Hash.new}
    end

    def create_mock_creator(subject, &definition)
      MockCreator.new(self, subject, &definition)
    end

    def create_stub_creator(subject, &definition)
      StubCreator.new(self, subject, &definition)
    end

    def create_probe_creator(subject, &definition)
      ProbeCreator.new(self, subject, &definition)
    end

    def create_scenario(double)
      scenario = Scenario.new
      double.register_scenario scenario
      scenario
    end

    def create_double(object, method_name)
      double = @doubles[object][method_name.to_sym]
      return double if double

      double = Double.new(self, object, method_name.to_sym)
      @doubles[object][method_name.to_sym] = double
      double.bind
      double
    end

    def verify_doubles
      @doubles.each do |object, method_double_map|
        method_double_map.keys.each do |method_name|
          verify_double(object, method_name)
        end
      end
    end

    def reset_doubles
      @doubles.each do |object, method_double_map|
        method_double_map.keys.each do |method_name|
          reset_double(object, method_name)
        end
      end
    end
    
    def verify_double(object, method_name)
      @doubles[object][method_name].verify
    ensure
      reset_double object, method_name
    end

    def reset_double(object, method_name)
      double = @doubles[object].delete(method_name)
      @doubles.delete(object) if @doubles[object].empty?
      double.reset
    end
  end
end