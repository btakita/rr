require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  describe DoubleInjection, "#object_has_original_method?" do
    before do
      @subject = Object.new
      @method_name = :to_s
      @double_injection = DoubleInjection.new(@subject, @method_name)
      class << @double_injection
        public :original_method_name
      end
    end

    it "returns true when method is still in object" do
      @double_injection.bind
      @double_injection.object_has_original_method?.should be_true
    end

    it "returns true when respond_to is true and methods include method" do
      @double_injection.bind
      def @subject.methods
        [:__rr_original_to_s]
      end
      def @subject.respond_to?(value)
        true
      end

      @double_injection.object_has_original_method?.should be_true
    end

    it "returns true when respond_to is true and methods do not include method" do
      @double_injection.bind
      def @subject.methods
        []
      end
      def @subject.respond_to?(value)
        true
      end

      @double_injection.object_has_original_method?.should be_true
    end

    it "returns false when respond_to is false and methods do not include method" do
      @double_injection.bind
      def @subject.methods
        []
      end
      def @subject.respond_to?(value)
        false
      end

      @double_injection.object_has_original_method?.should be_false
    end
  end
end
