module RR
  class ProcFromBlock < Proc
    def ==(other)
      Proc.new(&self) == other
    end
  end
end