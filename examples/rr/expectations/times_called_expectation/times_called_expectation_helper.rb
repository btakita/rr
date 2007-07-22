module RR
module Expectations
  describe TimesCalledExpectation, :shared => true do
    before do
      @space = Space.new
      @object = Object.new
      @method_name = :foobar
      @double = @space.create_double(@object, @method_name)
      @scenario = @space.scenario(@double)
      @scenario.with_any_args
    end

    def raises_expectation_error(&block)
      proc {block.call}.should raise_error(Errors::TimesCalledError)
    end
  end
end
end
