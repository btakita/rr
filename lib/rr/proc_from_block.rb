module RR
  if RUBY_VERSION =~ /^1.8/
    class ProcFromBlock < Proc
      def ==(other)
        Proc.new(&self) == other
      end
    end
  else
    ProcFromBlock = Proc
  end
end
