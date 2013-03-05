require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

module RR
  describe ProcFromBlock do
    describe "#==" do
      it "acts the same as #== on a Proc" do
        original_proc = lambda {}
        expect(Proc.new(&original_proc)).to eq original_proc

        expect(ProcFromBlock.new(&original_proc)).to eq original_proc
      end
    end
  end
end
