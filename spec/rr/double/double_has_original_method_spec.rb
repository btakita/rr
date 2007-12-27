require "spec/spec_helper"

module RR
describe Double, "#object_has_original_method?" do
  before do
    @space = Space.new
    @object = Object.new
    @method_name = :to_s
    @double = Double.new(@space, @object, @method_name)
    class << @double
      public :original_method_name
    end
  end

  it "returns true when method is still in object" do
    @double.bind
    @double.object_has_original_method?.should be_true
  end

  it "returns true when respond_to is true and methods include method" do
    @double.bind
    def @object.methods
      [:__rr_original_to_s]
    end
    def @object.respond_to?(value)
      true
    end

    @double.object_has_original_method?.should be_true
  end
  
  it "returns true when respond_to is true and methods do not include method" do
    @double.bind
    def @object.methods
      []
    end
    def @object.respond_to?(value)
      true
    end

    @double.object_has_original_method?.should be_true
  end

  it "returns false when respond_to is false and methods do not include method" do
    @double.bind
    def @object.methods
      []
    end
    def @object.respond_to?(value)
      false
    end

    @double.object_has_original_method?.should be_false
  end
end
end
