module RR
module Errors
  BACKTRACE_IDENTIFIER = /lib\/rr/

  class RRError < RuntimeError
    def backtrace
      original_backtrace = super
      return original_backtrace unless RR::Space.trim_backtrace

      return original_backtrace unless original_backtrace.respond_to?(:each)
      new_backtrace = []
      original_backtrace.each do |line|
        new_backtrace << line unless line =~ BACKTRACE_IDENTIFIER
      end
      new_backtrace
    end
  end
end
end