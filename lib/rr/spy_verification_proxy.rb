module RR
  class SpyVerificationProxy
    instance_methods.each do |m|
      unless m =~ /^_/ || m.to_s == 'object_id' || m.to_s == "instance_eval" || m.to_s == 'respond_to?'
        alias_method "__blank_slated_#{m}", m
        undef_method m
      end
    end

    def initialize(subject)
      @subject = subject
    end
  
    def method_missing(method_name, *args, &block)
      SpyVerification.new(@subject, method_name, args)
    end  
  end
end