require "spec/example_helper"

module RR
module Extensions
  describe InstanceMethods, " space example", :shared => true do
    it_should_behave_like "RR::Extensions::InstanceMethods"
    before do
      @old_space = Space.instance

      @space = Space.new
      Space.instance = @space
      @object1 = Object.new
      @object2 = Object.new
      @method_name = :foobar
    end

    after do
      Space.instance = @old_space
    end
  end

  describe InstanceMethods, "#verify" do
    it_should_behave_like "RR::Extensions::InstanceMethods space example"

    it "#verify verifies and deletes the doubles" do
      verifies_all_doubles {verify}
    end

    it "#rr_verify verifies and deletes the doubles" do
      verifies_all_doubles {rr_verify}
    end

    def verifies_all_doubles
      double1 = @space.double(@object1, @method_name)
      double1_verify_calls = 0
      double1_reset_calls = 0
      (class << double1; self; end).class_eval do
        define_method(:verify) do ||
          double1_verify_calls += 1
        end
        define_method(:reset) do ||
          double1_reset_calls += 1
        end
      end
      double2 = @space.double(@object2, @method_name)
      double2_verify_calls = 0
      double2_reset_calls = 0
      (class << double2; self; end).class_eval do
        define_method(:verify) do ||
          double2_verify_calls += 1
        end
        define_method(:reset) do ||
          double2_reset_calls += 1
        end
      end

      yield
      double1_verify_calls.should == 1
      double2_verify_calls.should == 1
      double1_reset_calls.should == 1
      double1_reset_calls.should == 1
    end
  end

  describe InstanceMethods, "#reset" do
    it_should_behave_like "RR::Extensions::InstanceMethods space example"

    it "#reset removes the ordered scenarios" do
      removes_ordered_scenarios {reset}
    end

    it "#rr_reset removes the ordered scenarios" do
      removes_ordered_scenarios {rr_reset}
    end

    it "#reset resets all doubles" do
      resets_all_doubles {reset}
    end

    it "#rr_reset resets all doubles" do
      resets_all_doubles {rr_reset}
    end

    def removes_ordered_scenarios
      double1 = @space.double(@object1, :foobar1)
      double2 = @space.double(@object1, :foobar2)

      scenario1 = @space.scenario(double1)
      scenario2 = @space.scenario(double2)

      scenario1.ordered
      scenario2.ordered

      @space.ordered_scenarios.should_not be_empty

      yield
      @space.ordered_scenarios.should be_empty
    end

    def resets_all_doubles
      double1 = @space.double(@object1, @method_name)
      double1_reset_calls = 0
      (class << double1; self; end).class_eval do
        define_method(:reset) do ||
          double1_reset_calls += 1
        end
      end
      double2 = @space.double(@object2, @method_name)
      double2_reset_calls = 0
      (class << double2; self; end).class_eval do
        define_method(:reset) do ||
          double2_reset_calls += 1
        end
      end

      yield
      double1_reset_calls.should == 1
      double2_reset_calls.should == 1
    end
  end
end
end